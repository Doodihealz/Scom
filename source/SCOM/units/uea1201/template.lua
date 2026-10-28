-- uea1201: Cyclone
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["collision"] = {
                ["centerOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["size"] = {
                    ["x"] = 1,
                    ["y"] = 0.2,
                    ["z"] = 1,
                },
            },
            ["deathImpact"] = {
                ["aboveWaterTargetsOnly"] = true,
                ["damage"] = 25,
                ["damageFriendly"] = true,
                ["damageRadius"] = 1,
                ["damageType"] = "Normal",
                ["firingTolerance"] = 2,
                ["label"] = "DeathImpact",
                ["weaponCategory"] = "Death",
            },
            ["exhaustVisual"] = {
                ["parityFollowUp"] = "dedicated-stateful-idle-cruise-contrail-vfx",
                ["policyVersion"] = "1.0.1",
                ["runtimeStatus"] = "disabled-incompatible-world-space-particle-fallback",
                ["sourceBones"] = {
                    [1] = "Exhaust_Right",
                    [2] = "Exhaust_Right01",
                },
                ["sourceContrailBones"] = {
                    [1] = "Left_Contrail",
                    [2] = "Right_Contrail",
                },
                ["sourceContrailEmitter"] = "effects/emitters/contrail_polytrail_01_emit.bp",
                ["sourceContrailEmitterSha256"] = "8e05c7fb5c47ec34ddb432b3bdc4c481099b38281aaf4317365f9057445f1b7f",
                ["sourceCruise"] = {
                    ["length"] = 0.6,
                    ["lifetime"] = 1,
                    ["thickness"] = 0.05,
                    ["vShift"] = -0.65,
                },
                ["sourceCruiseEmitter"] = "effects/emitters/air_move_trail_beam_03_emit.bp",
                ["sourceCruiseEmitterSha256"] = "abaf5ebc736397f8580e17602d9f5b2b8eadb93418b2013a74e92f06ce9019ea",
                ["sourceEffectsArchiveSha256"] = "f0dcbf76b2c3381e7d9ebbd7e09613e046875f6ba3a788406e5635768e28a300",
                ["sourceIdle"] = {
                    ["length"] = 0.18,
                    ["lifetime"] = 1,
                    ["thickness"] = 0.045,
                    ["vShift"] = -0.45,
                },
                ["sourceIdleEmitter"] = "effects/emitters/air_idle_trail_beam_01_emit.bp",
                ["sourceIdleEmitterSha256"] = "2c17ccb8da1e1f35b2abd82040e58eae559fc0f76e0a6c8304006e23b55c5e95",
                ["sourceMode"] = "BeamExhaust",
            },
            ["footprint"] = {
                ["sourceMaxSlope"] = 0.25,
                ["x"] = 1,
                ["y"] = 1,
            },
            ["movement"] = {
                ["nativeAccelerationFallback"] = 15,
                ["nativeOrbitRange"] = 6.366197723675814,
                ["nativeOrbitSpeed"] = 10,
                ["nativeRotationSpeedFallback"] = 90,
                ["sourceAutoLandTime"] = 1,
                ["sourceBankFactor"] = 2,
                ["sourceBankForward"] = false,
                ["sourceBreakOffDistance"] = 5,
                ["sourceBreakOffTrigger"] = 15,
                ["sourceCanFly"] = true,
                ["sourceCombatTurnSpeed"] = 1.5,
                ["sourceElevation"] = 18,
                ["sourceEngageDistance"] = 50,
                ["sourceFuelRechargeRate"] = 5,
                ["sourceFuelUseTime"] = 300,
                ["sourceKLift"] = 3,
                ["sourceKLiftDamping"] = 2.5,
                ["sourceKMove"] = 1,
                ["sourceKMoveDamping"] = 1,
                ["sourceKRoll"] = 2,
                ["sourceKRollDamping"] = 1,
                ["sourceKTurn"] = 1,
                ["sourceKTurnDamping"] = 1.5,
                ["sourceLiftFactor"] = 7,
                ["sourceMaxAirspeed"] = 15,
                ["sourceMinAirspeed"] = 10,
                ["sourceMotionType"] = "RULEUMT_Air",
                ["sourcePhysicsMaxSpeed"] = 0.5,
                ["sourceStartTurnDistance"] = 5,
                ["sourceTightTurnMultiplier"] = 1.02,
                ["sourceTurnSpeed"] = 1.5,
                ["sourceWinged"] = true,
            },
            ["selection"] = {
                ["size"] = {
                    ["x"] = 0.6,
                    ["y"] = 0.65,
                },
                ["thickness"] = 0.65,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEA0102/UEA0102_unit.bp",
            ["sourceBlueprintSha256"] = "47d0b30c6c5e4a834614dd11134a11d49a90f727bac7995e54c24f0ddbfb1c26",
            ["sourceCategories"] = {
                [1] = "PRODUCTSC1",
                [2] = "SELECTABLE",
                [3] = "BUILTBYTIER1FACTORY",
                [4] = "BUILTBYTIER2FACTORY",
                [5] = "BUILTBYTIER3FACTORY",
                [6] = "UEF",
                [7] = "MOBILE",
                [8] = "AIR",
                [9] = "HIGHALTAIR",
                [10] = "TECH1",
                [11] = "ANTIAIR",
                [12] = "VISIBLETORECON",
                [13] = "RECLAIMABLE",
                [14] = "OVERLAYANTIAIR",
            },
            ["sourceId"] = "UEA0102",
            ["sourceSizeSphere"] = 1.6,
            ["targetId"] = "uea1201",
            ["weapons"] = {
                [1] = {
                    ["damage"] = 50,
                    ["firingTolerance"] = 0,
                    ["label"] = "LinkedRailGun",
                    ["maxRadius"] = 25,
                    ["muzzleBones"] = {
                        [1] = "Muzzle",
                    },
                    ["muzzleSalvoDelay"] = 0,
                    ["muzzleSalvoSize"] = 1,
                    ["muzzleVelocity"] = 120,
                    ["projectileLifetimeUsesMultiplier"] = 1.25,
                    ["projectilesPerOnFire"] = 1,
                    ["rackBone"] = "Muzzle",
                    ["rateOfFire"] = 1,
                    ["sourceProjectile"] = "projectiles/TAARailgun01/TAARailgun01_proj.bp",
                    ["sourceProjectileArchiveSha256"] = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
                    ["sourceProjectileScript"] = "projectiles/TAARailgun01/TAARailgun01_script.lua",
                    ["sourceProjectileScriptSha256"] = "36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e",
                    ["sourceProjectileSha256"] = "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f",
                    ["targetDisallow"] = "UNTARGETABLE,LAND,STRUCTURE,NAVAL",
                    ["targetLayers"] = {
                        [1] = "Air",
                    },
                    ["targetOnly"] = "AIR",
                    ["weaponLayers"] = {
                        [1] = "Air",
                        [2] = "Land",
                    },
                },
            },
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
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.65,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1511",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod5110",
        },
        ["onImpact"] = {
            ["looping"] = false,
            ["name"] = "aeod5210",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 0.2,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 295,
            ["regen"] = 0,
            ["value"] = 295,
        },
    },
    ["economy"] = {
        ["buildTime"] = 500,
        ["cost"] = {
            ["alloys"] = 50,
            ["energy"] = 2250,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAAirUnit",
        },
        ["displayName"] = "Cyclone",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "aa",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_antiAir.png",
        ["iconUIBuildSortPriority"] = 30,
        ["iconUIType"] = "air",
        ["name"] = "Cyclone",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 131.1,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uea1201",
        ["unitTypeName"] = "EDAT1AAFighter",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
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
        ["landWhenIdleSeconds"] = 1,
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
        ["sortOrder"] = 1,
        ["speed"] = 15,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
    },
    ["tags"] = {
        [1] = "AIR",
        [2] = "ANTI_AIR",
        [3] = "BUILDABLE_BY_T1_FACTORY",
        [4] = "BUILDABLE_BY_T2_FACTORY",
        [5] = "BUILDABLE_BY_T3_FACTORY",
        [6] = "EDA",
        [7] = "FIGHTER",
        [8] = "MOBILE",
        [9] = "TECH1",
        [10] = "SCFA_AIR",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_ANTIAIR",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_HIGHALTAIR",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_OVERLAYANTIAIR",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_TECH1",
        [23] = "SCFA_UEF",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/SCOM/Death/ved3101_death_air_small.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved1101_death_crashland_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.05,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.036,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.05600000000000001,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.084,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.08000000000000002,
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
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.65,
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
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Muzzle",
                    ["pitchMax"] = 55,
                    ["pitchMin"] = -55,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 0,
                    ["projectileSpeed"] = 120,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Muzzle",
                    ["yawMax"] = 55,
                    ["yawMin"] = -55,
                    ["yawSpeed"] = 360,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom1112",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 50,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uea1201/muzzle_linkedrailgun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
                [2] = "Land",
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
            ["projectileLifetime"] = 0.2604166666666667,
            ["projectileTemplate"] = "psf0025",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LinkedRailGun",
                ["sourceProjectile"] = "/projectiles/TAARailgun01/TAARailgun01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LinkedRailGun",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 25,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
