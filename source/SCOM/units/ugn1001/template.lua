-- ugn1001: Tier 1: Trident Class
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "04C8E375EEBC47A75A5F6123F44E6E13B6BE2A9D9B33983BED05FD25A78942D7",
            ["sourceId"] = "URS0103",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.09,
            ["targetId"] = "ugn1001",
            ["textureResolution"] = 2048,
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "URS0103",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 16.66666603088379,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 14.850000381469727,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 14.850000381469727,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1.2,
                    ["rateMin"] = 0.8,
                    ["weight"] = 100,
                },
            },
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URS0103",
            ["targetId"] = "ugn1001",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 3,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.175,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 1.1,
            ["z"] = 4.3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1900,
            ["regen"] = 0,
            ["value"] = 1900,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1250,
        ["cost"] = {
            ["alloys"] = 250,
            ["energy"] = 2500,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardNavalUnit",
        },
        ["displayName"] = "Tier 1: Trident Class",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Trident Class",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ugn1001",
    },
    ["intel"] = {
        ["radarRadius"] = 80,
        ["sonarRadius"] = 82,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 6,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 6,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 60,
        ["sortOrder"] = 5,
        ["speed"] = 6,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 80,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 82,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 48,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_FACTORY",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "GUARD",
        [5] = "MOBILE",
        [6] = "NAVAL",
        [7] = "FRIGATE",
        [8] = "TECH1",
        [9] = "ANTI_AIR",
        [10] = "ANTI_SURFACE",
        [11] = "DIRECT_FIRE",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_ANTIAIR",
        [14] = "SCFA_BUILTBYTIER1FACTORY",
        [15] = "SCFA_BUILTBYTIER2FACTORY",
        [16] = "SCFA_BUILTBYTIER3FACTORY",
        [17] = "SCFA_COUNTERINTELLIGENCE",
        [18] = "SCFA_CYBRAN",
        [19] = "SCFA_DIRECTFIRE",
        [20] = "SCFA_FRIGATE",
        [21] = "SCFA_INTELLIGENCE",
        [22] = "SCFA_MOBILE",
        [23] = "SCFA_NAVAL",
        [24] = "SCFA_OVERLAYANTIAIR",
        [25] = "SCFA_OVERLAYDIRECTFIRE",
        [26] = "SCFA_OVERLAYRADAR",
        [27] = "SCFA_OVERLAYSONAR",
        [28] = "SCFA_PRODUCTSC1",
        [29] = "SCFA_RADAR",
        [30] = "SCFA_RECLAIMABLE",
        [31] = "SCFA_SELECTABLE",
        [32] = "SCFA_SONAR",
        [33] = "SCFA_TECH1",
        [34] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAsink",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAsink02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAsink03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
            },
            ["source_animafloat_1"] = {
                ["clipName"] = "AnimAfloat",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
            },
            ["source_animasink02_3"] = {
                ["clipName"] = "AnimAsink02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
            },
            ["source_animasink03_4"] = {
                ["clipName"] = "AnimAsink03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
            },
            ["source_animasink_2"] = {
                ["clipName"] = "AnimAsink",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1001/LOD0/ugn1001.sananimation",
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
                    ["x"] = 0.108,
                    ["y"] = 0.45,
                    ["z"] = -0.86,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.373,
                    ["z"] = 0.7739999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.48300000000000004,
                    ["z"] = 0.688,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.637,
                    ["z"] = -0.86,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.615,
                    ["z"] = 0.7739999999999999,
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
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 3,
            },
            ["thickness"] = 0.23,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Front_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Front_Turret_Barrel",
                    ["pitchMax"] = 30,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Front_Turret",
                    ["yawMax"] = 160,
                    ["yawMin"] = -160,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 40,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn1001/muzzle_protoncannon.sanvfx",
            },
            ["firingRandomness"] = 0.2,
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
                        [1] = "Front_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Front_Muzzle"] = {
                    ["aimController"] = "Front_Muzzle",
                },
            },
            ["name"] = "ProtonCannon",
            ["projectileLifetime"] = 1.5,
            ["projectileTemplate"] = "psf0094",
            ["rangeMax"] = 28,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.653594771,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "c5e63eb0c5ad7ca4b64671457477b19af709d0c2208f8996e507d9035d4d6c1c",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ProtonCannon",
                ["sourceProjectile"] = "/projectiles/CDFProtonCannon04/CDFProtonCannon04_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ProtonCannon",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Back_Turret_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Back_Turret_Barrel",
                    ["pitchMax"] = 40,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Back_Turret_AA",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
                [2] = {
                    ["aimBone"] = "Back_Turret_Muzzle03",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Back_Turret_Barrel",
                    ["pitchMax"] = 40,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Back_Turret_AA",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 3,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn1001/muzzle_aagun.sanvfx",
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
                        [1] = "Back_Turret_Muzzle01",
                        [2] = "Back_Turret_Muzzle02",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret_Muzzle03",
                        [2] = "Back_Turret_Muzzle04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Back_Turret_Muzzle01"] = {
                    ["aimController"] = "Back_Turret_Muzzle01",
                },
                ["Back_Turret_Muzzle02"] = {
                    ["aimController"] = "Back_Turret_Muzzle01",
                },
                ["Back_Turret_Muzzle03"] = {
                    ["aimController"] = "Back_Turret_Muzzle03",
                },
                ["Back_Turret_Muzzle04"] = {
                    ["aimController"] = "Back_Turret_Muzzle03",
                },
            },
            ["name"] = "AAGun",
            ["projectileLifetime"] = 2.13333333,
            ["projectileTemplate"] = "psf0004",
            ["rangeMax"] = 48,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0460b42285f54f1b3cd041b431805ab8a0d54c1d6246c0ba26d6980156f19152",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/CAAAutocannon01/CAAAutocannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
