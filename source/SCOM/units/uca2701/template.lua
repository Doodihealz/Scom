-- uca2701: Solace
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca2701/LOD0/uca2701_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "d6107d85d8b4b43c5d8f30987e7d021c64febc82cce957cae9598bcbea626f41",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["sonarRadius"] = 90,
                },
                ["runtimeSupported"] = {
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
            ["sourceBlueprint"] = "units/XAA0306/XAA0306_unit.bp",
            ["sourceBlueprintSha256"] = "8914143f45b075d4616c69e38b909ffc806e37687bdc9c9d71076a1b3d71116a",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "ANTINAVY",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "HIGHALTAIR",
                [6] = "MOBILE",
                [7] = "OVERLAYSONAR",
                [8] = "PRODUCTFA",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "TECH3",
                [12] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 25,
            ["sourceId"] = "XAA0306",
            ["sourceKLift"] = 3,
            ["sourceKLiftDamping"] = 2.5,
            ["sourceLiftFactor"] = 7,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca2701",
            ["weapons"] = {
                [1] = {
                    ["label"] = "Bomb",
                    ["muzzleSalvoSize"] = 4,
                    ["projectilesPerOnFire"] = 4,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 2,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Torpedo_Muzzle",
                            },
                            ["rackBone"] = "Torpedo_Muzzle",
                        },
                    },
                    ["rateOfFire"] = 0.08,
                    ["reloadTime"] = 12.5,
                    ["sourceCategory"] = "Anti Navy",
                    ["sourceProjectile"] = "/projectiles/AANTorpedoCluster01/AANTorpedoCluster01_proj.bp",
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
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.04999999999999999,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.6,
                ["y"] = 1.2,
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
            ["y"] = 0.04999999999999999,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.5,
            ["y"] = 0.5,
            ["z"] = 1.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3750,
            ["regen"] = 0,
            ["value"] = 3750,
        },
    },
    ["economy"] = {
        ["buildTime"] = 6600,
        ["cost"] = {
            ["alloys"] = 1650,
            ["energy"] = 55000,
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
        ["displayName"] = "Solace",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Solace",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uca2701",
        ["unitTypeName"] = "Solace",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 20,
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
        ["minSpeed"] = 18,
        ["orbitRange"] = 11.459155902616464,
        ["orbitSpeed"] = 18,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 11.459155902616464,
                    ["speed"] = 18,
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
        ["preferredAltitude"] = 25,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 20,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 4,
            ["outerRadius"] = 42,
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
        [2] = "ANTI_NAVAL",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CHOSEN",
        [5] = "MOBILE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_AIR",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ANTINAVY",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_HIGHALTAIR",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_OVERLAYSONAR",
        [15] = "SCFA_PRODUCTFA",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_TECH3",
        [19] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca2701/LOD0/uca2701.sananimation",
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
                    ["x"] = 0.27,
                    ["y"] = 0.175,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.13999999999999999,
                    ["z"] = 0.27,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30000000000000004,
                    ["y"] = 0.19,
                    ["z"] = 0.24,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 0.26,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.25,
                    ["z"] = 0.27,
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
                ["y"] = 0.04999999999999999,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.6,
                ["y"] = 1.2,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Torpedo_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Torpedo_Muzzle",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 14,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Torpedo_Muzzle",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 500,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca2701/muzzle_bomb.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Torpedo_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.4,
            ["muzzleSalvoSize"] = 8,
            ["muzzles"] = {
                ["Torpedo_Muzzle"] = {
                    ["aimController"] = "Torpedo_Muzzle",
                },
            },
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "psf0055",
            ["rangeMax"] = 42,
            ["rangeMin"] = 4,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 12.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "cc6baf4b45f59f320ad1c5d98ceaefc5d680385097756209d1213a03362acbb8",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Bomb",
                ["sourceProjectile"] = "/projectiles/AANTorpedoCluster01/AANTorpedoCluster01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Navy",
            ["scoSourceLabel"] = "Bomb",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Bomb",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 150,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
