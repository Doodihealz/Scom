-- uen1001: Tier 1: Thunderhead Class
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "D1D0924388DDB3B306BC3DBCECB49914E709814A056A5B44119896BD05D80A72",
            ["sourceId"] = "UES0103",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.09,
            ["targetId"] = "uen1001",
            ["textureResolution"] = 2048,
        },
        ["scoFieldFixPrefabCompletion"] = "1.0.1",
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "UES0103",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 23.33333396911621,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 20,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 30,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
            },
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "UES0103",
            ["targetId"] = "uen1001",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 2.75,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.15,
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
            ["max"] = 2120,
            ["regen"] = 0,
            ["value"] = 2120,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1300,
        ["cost"] = {
            ["alloys"] = 260,
            ["energy"] = 2600,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDANavalUnit",
        },
        ["displayName"] = "Tier 1: Thunderhead Class",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Thunderhead Class",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uen1001",
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
        [4] = "EDA",
        [5] = "MOBILE",
        [6] = "NAVAL",
        [7] = "FRIGATE",
        [8] = "TECH1",
        [9] = "ANTI_AIR",
        [10] = "ANTI_SURFACE",
        [11] = "DIRECT_FIRE",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_COUNTERINTELLIGENCE",
        [17] = "SCFA_DIRECTFIRE",
        [18] = "SCFA_FRIGATE",
        [19] = "SCFA_INTELLIGENCE",
        [20] = "SCFA_MOBILE",
        [21] = "SCFA_NAVAL",
        [22] = "SCFA_OVERLAYANTIAIR",
        [23] = "SCFA_OVERLAYCOUNTERINTEL",
        [24] = "SCFA_OVERLAYDIRECTFIRE",
        [25] = "SCFA_OVERLAYRADAR",
        [26] = "SCFA_OVERLAYSONAR",
        [27] = "SCFA_PRODUCTSC1",
        [28] = "SCFA_RADAR",
        [29] = "SCFA_RECLAIMABLE",
        [30] = "SCFA_SELECTABLE",
        [31] = "SCFA_SONAR",
        [32] = "SCFA_TECH1",
        [33] = "SCFA_UEF",
        [34] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimA001",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
            },
            ["source_anima001_1"] = {
                ["clipName"] = "AnimA001",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
            },
            ["source_anima002_2"] = {
                ["clipName"] = "AnimA002",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
            },
            ["source_animadeath01_3"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
            },
            ["source_animadeath02_4"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen1001/LOD0/uen1001.sananimation",
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
                    ["y"] = 0.42500000000000004,
                    ["z"] = -0.86,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.348,
                    ["z"] = 0.7739999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.4580000000000001,
                    ["z"] = 0.688,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.612,
                    ["z"] = -0.86,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.5900000000000001,
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
                ["y"] = 0.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 2.75,
            },
            ["thickness"] = 0.25,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Front_Turret_Muzzle",
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
                    ["pitchMax"] = 20,
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
            ["damage"] = 140,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen1001/muzzle_maingun.sanvfx",
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
                        [1] = "Front_Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Front_Turret_Muzzle"] = {
                    ["aimController"] = "Front_Turret_Muzzle",
                },
            },
            ["name"] = "MainGun",
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0151",
            ["rangeMax"] = 28,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2.85714286,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "7b4cf765e643ae78c849338be82943eaba000aa10d03565dcd717182aed63460",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/TDFGauss01/TDFGauss01_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
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
                    ["pitchBone"] = "Back_Turret_Barrel01",
                    ["pitchMax"] = 40,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Back_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
                [2] = {
                    ["aimBone"] = "Back_Turret_Muzzle02",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Back_Turret_Barrel02",
                    ["pitchMax"] = 40,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Back_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 7,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen1001/muzzle_aagun.sanvfx",
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
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Back_Turret_Muzzle01"] = {
                    ["aimController"] = "Back_Turret_Muzzle01",
                },
                ["Back_Turret_Muzzle02"] = {
                    ["aimController"] = "Back_Turret_Muzzle02",
                },
            },
            ["name"] = "AAGun",
            ["projectileLifetime"] = 2.13333333,
            ["projectileTemplate"] = "psf0025",
            ["rangeMax"] = 48,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/TAARailgun01/TAARailgun01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
