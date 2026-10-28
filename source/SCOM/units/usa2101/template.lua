-- usa2101: Notha
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSurfaceBomberSourceContract"] = {
            ["nativeAhwassaSpeedScale"] = 1,
            ["nativeGravityFallback"] = 4.9,
            ["nativeGravitySourceOwned"] = false,
            ["runtimeProjectileId"] = "psb202",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBaseBreakOffDistance"] = 5,
            ["sourceBaseBreakOffTrigger"] = 10,
            ["sourceBlueprint"] = "units/XSA0202/XSA0202_unit.bp",
            ["sourceBlueprintSha256"] = "b0e15d543fdd34b0ecf3521380f41a5c0b4ef0a628b9677b2a84bf4e0a44d1dc",
            ["sourceBombTargetBreakOffDistanceMultiplier"] = 8,
            ["sourceBombTargetBreakOffTriggerMultiplier"] = 2,
            ["sourceBombTargetSpeedMultiplier"] = 0.67,
            ["sourceMaxAirspeed"] = 15,
            ["sourceMinAirspeed"] = 10,
            ["sourcePhysicsMaxSpeed"] = 0.5,
            ["sourceProjectileArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            ["sourceProjectileBlueprint"] = "projectiles/SBOOtheTacticalBomb02/SBOOtheTacticalBomb02_proj.bp",
            ["sourceProjectileBlueprintSha256"] = "1f96bc42cae307c9e116b960e7dc8f0955baf831f17ac1409b91796e1fc4c5cb",
            ["sourceProjectileId"] = "SBOOtheTacticalBomb02",
            ["sourceProjectileMaxSpeed"] = 20,
            ["sourceProjectileScript"] = "projectiles/SBOOtheTacticalBomb02/SBOOtheTacticalBomb02_script.lua",
            ["sourceProjectileScriptSha256"] = "601d17860a124be6a0acbe6be5cb331ca5d54a6a04c57f09399b7d9c308a5dbe",
            ["sourceScript"] = "units/XSA0202/XSA0202_Script.lua",
            ["sourceScriptSha256"] = "d63f137391f722128f62f799cba71308854ee86daef792864c33623d89119f9d",
            ["sourceUnitId"] = "XSA0202",
            ["targetUnitId"] = "usa2101",
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
            ["sourceBreakOffDistance"] = 40,
            ["sourceBreakOffIfNearNewTarget"] = true,
            ["sourceBreakOffTrigger"] = 20,
            ["sourceEngageDistance"] = 50,
            ["version"] = "1.0.0",
        },
        ["scoMissingCrashImpact"] = {
            ["damage"] = 25,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["sourceBlueprintSha256"] = "b0e15d543fdd34b0ecf3521380f41a5c0b4ef0a628b9677b2a84bf4e0a44d1dc",
            ["sourceId"] = "XSA0202",
            ["sourceIndex"] = 4,
            ["targetId"] = "usa2101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.75,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod5120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 0.2,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1175,
            ["regen"] = 0,
            ["value"] = 1175,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2400,
        ["cost"] = {
            ["alloys"] = 420,
            ["energy"] = 8400,
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
        ["displayName"] = "Notha",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "none",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_air1_none.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "air",
        ["name"] = "Notha",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usa2101",
        ["unitTypeName"] = "UnknownT2DroneCarrier",
    },
    ["intel"] = {
        ["radarRadius"] = 65,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 15,
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
                    ["matchTargetSpeed"] = true,
                    ["runOutLength"] = 14.324,
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
        ["sortOrder"] = 5,
        ["speed"] = 15,
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
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 30,
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
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "DRONE_CARRIER",
        [4] = "INTEL",
        [5] = "MOBILE",
        [6] = "RADAR",
        [7] = "SCFA_AIR",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ANTIAIR",
        [10] = "SCFA_BUILTBYTIER2FACTORY",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_HIGHALTAIR",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_OVERLAYANTIAIR",
        [15] = "SCFA_OVERLAYRADAR",
        [16] = "SCFA_PRODUCTFA",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SERAPHIM",
        [20] = "SCFA_TECH2",
        [21] = "SCFA_VISIBLETORECON",
        [22] = "SERAPHIM",
        [23] = "TECH2",
        [24] = "AIR",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usa2101/LOD0/usa2101.sananimation",
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd3201_death_air_medium.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd3201_death_air_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.15000000000000002,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.136,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.15600000000000003,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.184,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.18000000000000002,
                    ["z"] = 0.18,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 107,
            ["lod1distance"] = 279,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.75,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_Left",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Muzzle_Left",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 120,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Muzzle_Left",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 25,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa2101/muzzle_shleoaagun01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Left",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle_Left"] = {
                    ["aimController"] = "Turret_Muzzle_Left",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0111",
            ["rangeMax"] = 30,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "9539620fea362f051a424ba168d0bb2efc9887e1a522037fd2a7f579f0a7c3c6",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ShleoAAGun01",
                ["sourceProjectile"] = "/projectiles/SAAShleoAAGatlingGun03/SAAShleoAAGatlingGun03_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ShleoAAGun01",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_Right",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Muzzle_Right",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 120,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Muzzle_Right",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 25,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa2101/muzzle_shleoaagun02.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Right",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle_Right"] = {
                    ["aimController"] = "Turret_Muzzle_Right",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0111",
            ["rangeMax"] = 30,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "9539620fea362f051a424ba168d0bb2efc9887e1a522037fd2a7f579f0a7c3c6",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "ShleoAAGun02",
                ["sourceProjectile"] = "/projectiles/SAAShleoAAGatlingGun03/SAAShleoAAGatlingGun03_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "ShleoAAGun02",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Bomb_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Bomb_Muzzle",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 0.0001,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Bomb_Muzzle",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 1175,
            ["damageFriendly"] = true,
            ["damageRadius"] = 3,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa2101/muzzle_bomb.sanvfx",
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
                        [1] = "Bomb_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Bomb_Muzzle"] = {
                    ["aimController"] = "Bomb_Muzzle",
                },
            },
            ["name"] = "Bomb",
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psb202",
            ["rangeMax"] = 40,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1,
            ["reloadTime"] = 10,
            ["scoFaBombDrop"] = {
                ["runtimeAimProjectileSpeed"] = 0.0001,
                ["runtimeForwardSpeedBonus"] = 3,
                ["runtimeGravity"] = 4.9,
                ["runtimeProjectileId"] = "psb202",
                ["runtimeProjectileLifetime"] = 8,
                ["runtimeReleaseMode"] = "PredictedHorizontalImpactThreshold",
                ["runtimeVelocityMode"] = "CarrierCurrentMovementSpeedPlusForwardBonus",
                ["sourceBombDropThreshold"] = 2,
                ["sourceMuzzleVelocity"] = 0,
                ["sourceNeedToComputeBombDrop"] = true,
                ["sourcePredictAheadForBombDrop"] = 3,
                ["sourceProjectileMaxSpeed"] = 20,
                ["sourceRealisticOrdinance"] = true,
                ["version"] = "1.0.0",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "Bomb",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
