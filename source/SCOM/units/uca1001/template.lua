-- uca1001: Shimmer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca1001/LOD0/uca1001_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "edb69ae2bbb35ab6a2b128821ac04bfd85d8ae4cee397e70d985c0c469533cf8",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["radarRadius"] = 65,
                    ["visionRadius"] = 32,
                },
            },
            ["movementCompatibility"] = "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAA0103/UAA0103_unit.bp",
            ["sourceBlueprintSha256"] = "c6d9d7169db4e2f2e49f85ce71c20181f6cc0be50e9b36b4064932a59053530e",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "BOMBER",
                [4] = "BUILTBYTIER1FACTORY",
                [5] = "BUILTBYTIER2FACTORY",
                [6] = "BUILTBYTIER3FACTORY",
                [7] = "HIGHALTAIR",
                [8] = "MOBILE",
                [9] = "OVERLAYRADAR",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SHOWATTACKRETICLE",
                [14] = "TECH1",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 18,
            ["sourceId"] = "UAA0103",
            ["sourceKLift"] = 3,
            ["sourceKLiftDamping"] = 2.5,
            ["sourceLiftFactor"] = 7,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca1001",
            ["weapons"] = {
                [1] = {
                    ["label"] = "Bomb",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Right_Projectile",
                            },
                            ["rackBone"] = "Right_Projectile",
                        },
                    },
                    ["rateOfFire"] = 0.5,
                    ["reloadTime"] = 2,
                    ["sourceCategory"] = "Bomb",
                    ["sourceProjectile"] = "/projectiles/AIFBombGraviton01/AIFBombGraviton01_proj.bp",
                },
                [2] = {
                    ["label"] = "DeathImpact",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {},
                    ["rateOfFire"] = 0,
                    ["reloadTime"] = 0,
                    ["sourceCategory"] = "Death",
                    ["sourceProjectile"] = "",
                },
            },
        },
        ["faSurfaceBomberSourceContract"] = {
            ["nativeAhwassaSpeedScale"] = 1,
            ["nativeGravityFallback"] = 4.9,
            ["nativeGravitySourceOwned"] = false,
            ["runtimeProjectileId"] = "pab101",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAA0103/UAA0103_unit.bp",
            ["sourceBlueprintSha256"] = "c6d9d7169db4e2f2e49f85ce71c20181f6cc0be50e9b36b4064932a59053530e",
            ["sourceMaxAirspeed"] = 10,
            ["sourceMinAirspeed"] = 10,
            ["sourcePhysicsMaxSpeed"] = 0.5,
            ["sourceProjectileArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            ["sourceProjectileBlueprint"] = "projectiles/AIFBombGraviton01/AIFBombGraviton01_proj.bp",
            ["sourceProjectileBlueprintSha256"] = "cdc00f032be9fea0ac4c6b9f5738b9f705052a05badfec72a45771f84f0f4c44",
            ["sourceProjectileId"] = "AIFBombGraviton01",
            ["sourceProjectileMaxSpeed"] = 40,
            ["sourceProjectileScript"] = "projectiles/AIFBombGraviton01/AIFBombGraviton01_script.lua",
            ["sourceProjectileScriptSha256"] = "ec40f79950401890363a06bcc1ade8e59ffb415cbe3b9831641db7e72d3f356b",
            ["sourceScript"] = "units/UAA0103/UAA0103_Script.lua",
            ["sourceScriptSha256"] = "62959bc318524975b2ecdcd86461bb4b280fa14f3192624ce96f8725767baf4a",
            ["sourceUnitId"] = "UAA0103",
            ["targetUnitId"] = "uca1001",
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
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.125,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 0.45,
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
            ["max"] = 205,
            ["regen"] = 0,
            ["value"] = 205,
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
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAirUnit",
        },
        ["displayName"] = "Shimmer",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Shimmer",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uca1001",
        ["unitTypeName"] = "Shimmer",
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
        ["orbitRange"] = 6.366197723675814,
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
                    ["radius"] = 6.366197723675814,
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
        [1] = "AIR",
        [2] = "BOMBER",
        [3] = "BUILDABLE_BY_T1_FACTORY",
        [4] = "BUILDABLE_BY_T2_FACTORY",
        [5] = "BUILDABLE_BY_T3_FACTORY",
        [6] = "CHOSEN",
        [7] = "INTEL",
        [8] = "MOBILE",
        [9] = "RADAR",
        [10] = "TECH1",
        [11] = "SCFA_AEON",
        [12] = "SCFA_AIR",
        [13] = "SCFA_ALLUNITS",
        [14] = "SCFA_BOMBER",
        [15] = "SCFA_BUILTBYTIER1FACTORY",
        [16] = "SCFA_BUILTBYTIER2FACTORY",
        [17] = "SCFA_BUILTBYTIER3FACTORY",
        [18] = "SCFA_HIGHALTAIR",
        [19] = "SCFA_MOBILE",
        [20] = "SCFA_OVERLAYRADAR",
        [21] = "SCFA_PRODUCTSC1",
        [22] = "SCFA_RECLAIMABLE",
        [23] = "SCFA_SELECTABLE",
        [24] = "SCFA_SHOWATTACKRETICLE",
        [25] = "SCFA_TECH1",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca1001/LOD0/uca1001.sananimation",
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
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd3101_death_air_small.sanvfx",
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
                ["x"] = 1.55,
                ["y"] = 0.45,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Projectile",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Projectile",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 0.0001,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Projectile",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 200,
            ["damageFriendly"] = true,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca1001/muzzle_bomb.sanvfx",
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
                        [1] = "Right_Projectile",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Projectile"] = {
                    ["aimController"] = "Right_Projectile",
                },
            },
            ["name"] = "Bomb",
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "pab101",
            ["rangeMax"] = 40,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 2,
            ["scoFaBombDrop"] = {
                ["runtimeAimProjectileSpeed"] = 0.0001,
                ["runtimeForwardSpeedBonus"] = 3,
                ["runtimeGravity"] = 4.9,
                ["runtimeProjectileId"] = "pab101",
                ["runtimeProjectileLifetime"] = 3,
                ["runtimeReleaseMode"] = "PredictedHorizontalImpactThreshold",
                ["runtimeVelocityMode"] = "CarrierCurrentMovementSpeedPlusForwardBonus",
                ["sourceBombDropThreshold"] = 1.5,
                ["sourceMuzzleVelocity"] = 0,
                ["sourceNeedToComputeBombDrop"] = true,
                ["sourcePredictAheadForBombDrop"] = 3,
                ["sourceProjectileMaxSpeed"] = 40,
                ["sourceRealisticOrdinance"] = true,
                ["version"] = "1.0.0",
            },
            ["scoSourceCategory"] = "Bomb",
            ["scoSourceLabel"] = "Bomb",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Bomb",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 100,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
