-- uca3001: Shocker
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca3001/LOD0/uca3001_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "f1c38cc0546bc7d41d32bb8dee88dac1f99041924e6e2426c4965e4b310e2c3c",
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
            ["sourceBlueprint"] = "units/UAA0304/UAA0304_unit.bp",
            ["sourceBlueprintSha256"] = "915bd856451b093319ffad7cb2cf988cec9df8b53a959edaefbfb9a69c1a062c",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "BOMBER",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "HIGHALTAIR",
                [6] = "MOBILE",
                [7] = "OVERLAYRADAR",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "SHOWATTACKRETICLE",
                [12] = "TECH3",
                [13] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 20,
            ["sourceId"] = "UAA0304",
            ["sourceKLift"] = 3,
            ["sourceKLiftDamping"] = 2.5,
            ["sourceLiftFactor"] = 7,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca3001",
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
                                [1] = "Muzzle",
                            },
                            ["rackBone"] = "Muzzle",
                        },
                    },
                    ["rateOfFire"] = 0.2,
                    ["reloadTime"] = 5,
                    ["sourceCategory"] = "Bomb",
                    ["sourceProjectile"] = "/projectiles/AIFBombQuark01/AIFBombQuark01_proj.bp",
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
            ["runtimeProjectileId"] = "pab301",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAA0304/UAA0304_unit.bp",
            ["sourceBlueprintSha256"] = "915bd856451b093319ffad7cb2cf988cec9df8b53a959edaefbfb9a69c1a062c",
            ["sourceMaxAirspeed"] = 17,
            ["sourceMinAirspeed"] = 15,
            ["sourcePhysicsMaxSpeed"] = 0.5,
            ["sourceProjectileArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            ["sourceProjectileBlueprint"] = "projectiles/AIFBombQuark01/AIFBombQuark01_proj.bp",
            ["sourceProjectileBlueprintSha256"] = "418285aaae897c7e47d2ac191105a27082950de3dddb663de2a49004776f8ba3",
            ["sourceProjectileId"] = "AIFBombQuark01",
            ["sourceProjectileMaxSpeed"] = 20,
            ["sourceProjectileScript"] = "projectiles/AIFBombQuark01/AIFBombQuark01_script.lua",
            ["sourceProjectileScriptSha256"] = "7ee67db187f1009c76785e983479240a0bc90eeffff44dd57cb0762fce15de50",
            ["sourceScript"] = "units/UAA0304/UAA0304_Script.lua",
            ["sourceScriptSha256"] = "fdaa62c52dd2848546047c18791af918a15f346260491329d0dfe14ab2e2fed6",
            ["sourceUnitId"] = "UAA0304",
            ["targetUnitId"] = "uca3001",
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
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0.2,
            },
            ["size"] = {
                ["x"] = 2,
                ["y"] = 1.3,
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
            ["max"] = 3800,
            ["regen"] = 0,
            ["value"] = 3800,
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
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAirUnit",
        },
        ["displayName"] = "Shocker",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Shocker",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uca3001",
        ["unitTypeName"] = "Shocker",
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
        ["orbitRange"] = 9.549296585513721,
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
                    ["radius"] = 9.549296585513721,
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
        [1] = "AIR",
        [2] = "BOMBER",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CHOSEN",
        [5] = "INTEL",
        [6] = "MOBILE",
        [7] = "RADAR",
        [8] = "TECH3",
        [9] = "SCFA_AEON",
        [10] = "SCFA_AIR",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BOMBER",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_HIGHALTAIR",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_OVERLAYRADAR",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SHOWATTACKRETICLE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca3001/LOD0/uca3001.sananimation",
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
                ["x"] = 2,
                ["y"] = 1.3,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Muzzle",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 0.0001,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Muzzle",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 3450,
            ["damageFriendly"] = true,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca3001/muzzle_bomb.sanvfx",
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
                        [1] = "Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Muzzle"] = {
                    ["aimController"] = "Muzzle",
                },
            },
            ["name"] = "Bomb",
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "pab301",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 5,
            ["scoFaBombDrop"] = {
                ["runtimeAimProjectileSpeed"] = 0.0001,
                ["runtimeForwardSpeedBonus"] = 3,
                ["runtimeGravity"] = 4.9,
                ["runtimeProjectileId"] = "pab301",
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
            ["damage"] = 500,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
