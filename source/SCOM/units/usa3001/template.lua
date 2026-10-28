-- usa3001: Sinntha
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSurfaceBomberSourceContract"] = {
            ["nativeAhwassaSpeedScale"] = 1,
            ["nativeGravityFallback"] = 4.9,
            ["nativeGravitySourceOwned"] = false,
            ["runtimeProjectileId"] = "psb301",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XSA0304/XSA0304_unit.bp",
            ["sourceBlueprintSha256"] = "8890281d908a9f0e996de289731718516b281a22e16b80e6ea99acb4dbb8039d",
            ["sourceMaxAirspeed"] = 17,
            ["sourceMinAirspeed"] = 15,
            ["sourcePhysicsMaxSpeed"] = 0.5,
            ["sourceProjectileArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            ["sourceProjectileBlueprint"] = "projectiles/SBOZhanaseeBomb01/SBOZhanaseeBomb01_proj.bp",
            ["sourceProjectileBlueprintSha256"] = "ca131429be3e508d043617e3fc522e6381eb579f6dc3c53dd70ccbd13a5e2428",
            ["sourceProjectileId"] = "SBOZhanaseeBomb01",
            ["sourceProjectileMaxSpeed"] = 20,
            ["sourceProjectileScript"] = "projectiles/SBOZhanaseeBomb01/SBOZhanaseeBomb01_script.lua",
            ["sourceProjectileScriptSha256"] = "a13dd7da0abeba1921d111adb8430cd065babe4e7ba1023fb10bd776a17b3382",
            ["sourceScript"] = "units/XSA0304/XSA0304_Script.lua",
            ["sourceScriptSha256"] = "00e68ca7dc39ffe01762e30a94422bd41614539ab1e39a2c705c3d083fecd55e",
            ["sourceUnitId"] = "XSA0304",
            ["targetUnitId"] = "usa3001",
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
            ["sourceBreakOffDistance"] = 60,
            ["sourceBreakOffIfNearNewTarget"] = true,
            ["sourceBreakOffTrigger"] = 30,
            ["sourceEngageDistance"] = 50,
            ["version"] = "1.0.0",
        },
        ["scoMissingCrashImpact"] = {
            ["damage"] = 500,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["sourceBlueprintSha256"] = "8890281d908a9f0e996de289731718516b281a22e16b80e6ea99acb4dbb8039d",
            ["sourceId"] = "XSA0304",
            ["sourceIndex"] = 2,
            ["targetId"] = "usa3001",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0.2,
            },
            ["size"] = {
                ["x"] = 2.3,
                ["y"] = 0.6,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod5130",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0.2,
        },
        ["collisionSize"] = {
            ["x"] = 2,
            ["y"] = 0.5,
            ["z"] = 1.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3900,
            ["regen"] = 0,
            ["value"] = 3900,
        },
    },
    ["economy"] = {
        ["buildTime"] = 8400,
        ["cost"] = {
            ["alloys"] = 2100,
            ["energy"] = 105000,
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
        ["displayName"] = "Sinntha",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Sinntha",
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
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usa3001",
        ["unitTypeName"] = "UnknownT3Bomber",
    },
    ["intel"] = {
        ["radarRadius"] = 65,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 17,
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
        ["minSpeed"] = 15,
        ["orbitRange"] = 9.54929658551372,
        ["orbitSpeed"] = 15,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 9.54929658551372,
                    ["speed"] = 15,
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
        ["preferredAltitude"] = 20,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 17,
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
            ["outerRadius"] = 90,
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
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "DIRECT_FIRE",
        [5] = "MOBILE",
        [6] = "SCFA_AIR",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BOMBER",
        [9] = "SCFA_BUILTBYTIER3FACTORY",
        [10] = "SCFA_HIGHALTAIR",
        [11] = "SCFA_MOBILE",
        [12] = "SCFA_OVERLAYRADAR",
        [13] = "SCFA_PRODUCTFA",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SERAPHIM",
        [17] = "SCFA_SHOWATTACKRETICLE",
        [18] = "SCFA_TECH3",
        [19] = "SCFA_VISIBLETORECON",
        [20] = "SERAPHIM",
        [21] = "TECH3",
        [22] = "AIR",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usa3001/LOD0/usa3001.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd3301_death_air_large.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd3301_death_air_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.375,
                    ["z"] = -0.12000000000000005,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.488,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 0.39,
                    ["z"] = 0.456,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.12000000000000005,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.45,
                    ["z"] = 0.488,
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
                ["y"] = 0.25,
                ["z"] = 0.2,
            },
            ["size"] = {
                ["x"] = 2.3,
                ["y"] = 0.6,
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
                    ["name"] = "aclm5132",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 3250,
            ["damageFriendly"] = true,
            ["damageRadius"] = 5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa3001/muzzle_bomb.sanvfx",
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
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psb301",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 5,
            ["scoFaBombDrop"] = {
                ["runtimeAimProjectileSpeed"] = 0.0001,
                ["runtimeForwardSpeedBonus"] = 3,
                ["runtimeGravity"] = 4.9,
                ["runtimeProjectileId"] = "psb301",
                ["runtimeProjectileLifetime"] = 8,
                ["runtimeReleaseMode"] = "PredictedHorizontalImpactThreshold",
                ["runtimeVelocityMode"] = "CarrierCurrentMovementSpeedPlusForwardBonus",
                ["sourceBombDropThreshold"] = 3.5,
                ["sourceMuzzleVelocity"] = 0,
                ["sourceNeedToComputeBombDrop"] = true,
                ["sourcePredictAheadForBombDrop"] = 3,
                ["sourceProjectileMaxSpeed"] = 20,
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
