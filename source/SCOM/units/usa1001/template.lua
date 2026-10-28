-- usa1001: Sinnve
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSurfaceBomberSourceContract"] = {
            ["nativeAhwassaSpeedScale"] = 1,
            ["nativeGravityFallback"] = 4.9,
            ["nativeGravitySourceOwned"] = false,
            ["runtimeProjectileId"] = "psb101",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XSA0103/XSA0103_unit.bp",
            ["sourceBlueprintSha256"] = "d23ca7e7cd8e1c17985fe9ab418ec458f6559201af1870ba67a08392ee667a2d",
            ["sourceMaxAirspeed"] = 10,
            ["sourceMinAirspeed"] = 10,
            ["sourcePhysicsMaxSpeed"] = 0.5,
            ["sourceProjectileArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            ["sourceProjectileBlueprint"] = "projectiles/SBOOtheTacticalBomb01/SBOOtheTacticalBomb01_proj.bp",
            ["sourceProjectileBlueprintSha256"] = "157076800c4a9cbb2c970ecd89065ba2d42304d0f5f6b23fd5765917fbf6a30b",
            ["sourceProjectileId"] = "SBOOtheTacticalBomb01",
            ["sourceProjectileMaxSpeed"] = 40,
            ["sourceProjectileScript"] = "projectiles/SBOOtheTacticalBomb01/SBOOtheTacticalBomb01_script.lua",
            ["sourceProjectileScriptSha256"] = "4a3d936e2ca311d20071945ce500c56154a1d3e097ffbf35aa38081f1c02cdc1",
            ["sourceScript"] = "units/XSA0103/XSA0103_Script.lua",
            ["sourceScriptSha256"] = "47e2e0b17df35f9824fe944a4cc45b3013e2045ce31355ecffe66a383be500a3",
            ["sourceUnitId"] = "XSA0103",
            ["targetUnitId"] = "usa1001",
            ["version"] = "1.0.0",
        },
        ["scoCargo"] = {
            ["airPortable"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["portable"] = false,
            ["slots"] = {},
            ["unfoldDuration"] = 0,
        },
        ["scoFaBomberAttackRun"] = {
            ["runtimeMode"] = "ReleaseBreakOffReentry",
            ["runtimePursueStandoff"] = 0,
            ["sourceBreakOffDistance"] = 30,
            ["sourceBreakOffIfNearNewTarget"] = true,
            ["sourceBreakOffTrigger"] = 20,
            ["sourceEngageDistance"] = 50,
            ["version"] = "1.0.0",
        },
        ["scoMissingCrashImpact"] = {
            ["damage"] = 100,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["sourceBlueprintSha256"] = "d23ca7e7cd8e1c17985fe9ab418ec458f6559201af1870ba67a08392ee667a2d",
            ["sourceId"] = "XSA0103",
            ["sourceIndex"] = 2,
            ["targetId"] = "usa1001",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.125,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.6,
                ["y"] = 0.7,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1530",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod5110",
        },
        ["onImpact"] = {
            ["looping"] = false,
            ["name"] = "acod5210",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.125,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2,
            ["y"] = 0.25,
            ["z"] = 0.625,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 210,
            ["regen"] = 0,
            ["value"] = 210,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 80,
            ["energy"] = 1400,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimAirUnit",
        },
        ["displayName"] = "Sinnve",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Sinnve",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 180.2,
            ["WaterSurface"] = 196.1,
        },
        ["tpId"] = "usa1001",
        ["unitTypeName"] = "UnknownT1Bomber",
    },
    ["intel"] = {
        ["radarRadius"] = 65,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 10,
        ["air"] = true,
        ["airHover"] = false,
        ["altitudeJitterFactor"] = 1,
        ["bankFactor"] = 1,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["landWhenIdleSeconds"] = 5,
        ["maxBankDegrees"] = 30,
        ["minSpeed"] = 10,
        ["orbitRange"] = 6.36619772367581,
        ["orbitSpeed"] = 10,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 6.36619772367581,
                    ["speed"] = 10,
                },
                ["mode"] = "Circle",
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
            ["cruise"] = {
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
            ["strafe"] = {
                ["mode"] = "Strafe",
                ["strafe"] = {
                    ["matchTargetSpeed"] = false,
                    ["runOutLength"] = 48,
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
        },
        ["preferredAltitude"] = 18,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 10,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 65,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 40,
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
        [1] = "ANTI_SURFACE",
        [2] = "BOMBER",
        [3] = "BUILDABLE_BY_T1_FACTORY",
        [4] = "BUILDABLE_BY_T2_FACTORY",
        [5] = "BUILDABLE_BY_T3_FACTORY",
        [6] = "DIRECT_FIRE",
        [7] = "MOBILE",
        [8] = "SCFA_AIR",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BOMBER",
        [11] = "SCFA_BUILTBYTIER1FACTORY",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_HIGHALTAIR",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_OVERLAYRADAR",
        [17] = "SCFA_PRODUCTFA",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SERAPHIM",
        [21] = "SCFA_SHOWATTACKRETICLE",
        [22] = "SCFA_TECH1",
        [23] = "SCFA_VISIBLETORECON",
        [24] = "SERAPHIM",
        [25] = "TECH1",
        [26] = "AIR",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usa1001/LOD0/usa1001.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
                    ["particleName"] = "VFX/SCOM/Death/vcd3101_death_air_small.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.1875,
                    ["z"] = -0.125,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.16999999999999998,
                    ["z"] = 0.11249999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 0.195,
                    ["z"] = 0.1,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.22999999999999998,
                    ["z"] = -0.125,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.225,
                    ["z"] = 0.11249999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 105,
            ["lod1distance"] = 275,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.125,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.6,
                ["y"] = 0.7,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Center_Projectile",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Center_Projectile",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 0.0001,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Center_Projectile",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom4112",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 250,
            ["damageFriendly"] = true,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa1001/muzzle_bomb.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Center_Projectile",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Center_Projectile"] = {
                    ["aimController"] = "Center_Projectile",
                },
            },
            ["name"] = "Bomb",
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "psb101",
            ["rangeMax"] = 40,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 2,
            ["scoFaBombDrop"] = {
                ["runtimeAimProjectileSpeed"] = 0.0001,
                ["runtimeForwardSpeedBonus"] = 3,
                ["runtimeGravity"] = 4.9,
                ["runtimeProjectileId"] = "psb101",
                ["runtimeProjectileLifetime"] = 3,
                ["runtimeReleaseMode"] = "PredictedHorizontalImpactThreshold",
                ["runtimeVelocityMode"] = "CarrierCurrentMovementSpeedPlusForwardBonus",
                ["sourceBombDropThreshold"] = 3,
                ["sourceMuzzleVelocity"] = 0,
                ["sourceNeedToComputeBombDrop"] = true,
                ["sourcePredictAheadForBombDrop"] = 3,
                ["sourceProjectileMaxSpeed"] = 40,
                ["sourceRealisticOrdinance"] = true,
                ["version"] = "1.0.0",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Bomb",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
