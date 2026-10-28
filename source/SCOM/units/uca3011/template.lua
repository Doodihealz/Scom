-- uca3011: Restorer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca3011/LOD0/uca3011_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "30a1b5b8ff5d4589c143e95fa1cf73f6a730c648c23c51d685214a6db5f01433",
            ["intel"] = {
                ["provenanceOnly"] = {},
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
            ["sourceBlueprint"] = "units/XAA0305/XAA0305_unit.bp",
            ["sourceBlueprintSha256"] = "2613f37cfda2ed1120a7406d3d974b440a1eed008517528f2633abd74481f661",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "ANTIAIR",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "GROUNDATTACK",
                [6] = "MOBILE",
                [7] = "OVERLAYANTIAIR",
                [8] = "OVERLAYDIRECTFIRE",
                [9] = "PRODUCTFA",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "TECH3",
                [13] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 10,
            ["sourceId"] = "XAA0305",
            ["sourceKLift"] = 3,
            ["sourceKLiftDamping"] = 2.5,
            ["sourceLiftFactor"] = 7,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca3011",
            ["weapons"] = {
                [1] = {
                    ["label"] = "Turret",
                    ["muzzleSalvoSize"] = 4,
                    ["projectilesPerOnFire"] = 4,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle03",
                                [2] = "Turret_Muzzle04",
                            },
                            ["rackBone"] = "C_Barrel",
                        },
                    },
                    ["rateOfFire"] = 1.25,
                    ["reloadTime"] = 0.8,
                    ["sourceCategory"] = "Direct Fire",
                    ["sourceProjectile"] = "/projectiles/ADFQuadLaserLight01/ADFQuadLaserLight01_proj.bp",
                },
                [2] = {
                    ["label"] = "AAGun01",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle01",
                            },
                            ["rackBone"] = "R_Barrel",
                        },
                    },
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAAZealotMissile02/AAAZealotMissile02_proj.bp",
                },
                [3] = {
                    ["label"] = "AAGun02",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle02",
                            },
                            ["rackBone"] = "L_Barrel",
                        },
                    },
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAAZealotMissile02/AAAZealotMissile02_proj.bp",
                },
                [4] = {
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
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.4,
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
            ["y"] = 0.175,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 0.5,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 6000,
            ["regen"] = 0,
            ["value"] = 6000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 4800,
        ["cost"] = {
            ["alloys"] = 1200,
            ["energy"] = 60000,
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
        ["displayName"] = "Restorer",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Restorer",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uca3011",
        ["unitTypeName"] = "Restorer",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 8,
        ["air"] = true,
        ["airHover"] = true,
        ["altitudeJitterFactor"] = 1,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["landWhenIdleSeconds"] = 5,
        ["maxBankDegrees"] = 0,
        ["minSpeed"] = 3,
        ["orbitRange"] = 5.092958178940651,
        ["orbitSpeed"] = 8,
        ["patternBySituation"] = {
            ["assist"] = "orbit",
            ["attack"] = "orbit",
            ["hold"] = "idle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["cruise"] = {
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                },
            },
            ["idle"] = {
                ["mode"] = "Orbit",
                ["orbit"] = {
                    ["acceleration"] = 2.167,
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["facing"] = "hold",
                    ["maxSpeed"] = 1.3,
                    ["radius"] = {
                        ["x"] = 0,
                        ["y"] = 0.15,
                    },
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                    ["syncToLateralPhase"] = true,
                },
            },
            ["orbit"] = {
                ["mode"] = "Orbit",
                ["orbit"] = {
                    ["acceleration"] = 2.167,
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["facing"] = "center",
                    ["maxSpeed"] = 1.3,
                    ["radius"] = {
                        ["x"] = 15,
                        ["y"] = 20,
                    },
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                    ["syncToLateralPhase"] = true,
                },
            },
        },
        ["preferredAltitude"] = 10,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 8,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Gunship",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
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
        [2] = "ANTI_AIR",
        [3] = "ANTI_SURFACE",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CHOSEN",
        [6] = "GUNSHIP",
        [7] = "MOBILE",
        [8] = "TECH3",
        [9] = "SCFA_AEON",
        [10] = "SCFA_AIR",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_ANTIAIR",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_GROUNDATTACK",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_OVERLAYANTIAIR",
        [17] = "SCFA_OVERLAYDIRECTFIRE",
        [18] = "SCFA_PRODUCTFA",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca3011/LOD0/uca3011.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.3,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.265,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.315,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.385,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.375,
                    ["z"] = 0.18,
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
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.4,
                ["y"] = 1.2,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle03",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = -20,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "C_Barrel",
                    ["pitchMax"] = 50,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 40,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "C_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 24,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca3011/muzzle_turret.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
                [2] = "Land",
                [3] = "WaterSurface",
                [4] = "Water",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle03",
                        [2] = "Turret_Muzzle04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 4,
            ["muzzles"] = {
                ["Turret_Muzzle03"] = {
                    ["aimController"] = "Turret_Muzzle03",
                },
                ["Turret_Muzzle04"] = {
                    ["aimController"] = "Turret_Muzzle03",
                },
            },
            ["projectileLifetime"] = 0.71875,
            ["projectileTemplate"] = "psf0065",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.8,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "a0700f144dc92d08729856e7fe949dd50a8ae1ff1652bd7127ce0703e400dc1f",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Turret",
                ["sourceProjectile"] = "/projectiles/ADFQuadLaserLight01/ADFQuadLaserLight01_proj.bp",
            },
            ["scoSourceCategory"] = "Direct Fire",
            ["scoSourceLabel"] = "Turret",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Turret",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 20,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "R_Barrel",
                    ["pitchMax"] = 200,
                    ["pitchMin"] = -160,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "R_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 65,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca3011/muzzle_aagun01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
            },
            ["projectileLifetime"] = 4,
            ["projectileTemplate"] = "psf0050",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "14b0d59d607a40d2cb214452e89bd3eea95fd25fb470677e6b864f1e2912c423",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun01",
                ["sourceProjectile"] = "/projectiles/AAAZealotMissile02/AAAZealotMissile02_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "AAGun01",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AAGun01",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle02",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 20,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "L_Barrel",
                    ["pitchMax"] = 200,
                    ["pitchMin"] = -160,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "L_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 65,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca3011/muzzle_aagun02.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle02"] = {
                    ["aimController"] = "Turret_Muzzle02",
                },
            },
            ["projectileLifetime"] = 4,
            ["projectileTemplate"] = "psf0050",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "14b0d59d607a40d2cb214452e89bd3eea95fd25fb470677e6b864f1e2912c423",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "AAGun02",
                ["sourceProjectile"] = "/projectiles/AAAZealotMissile02/AAAZealotMissile02_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "AAGun02",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "AAGun02",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 100,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
