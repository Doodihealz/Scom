-- uca3201: Corona
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca3201/LOD0/uca3201_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "33326c708f83f52a2d5e3389a14eecc5d19f78273aa0ade97fa162732bb0f79f",
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
            ["sourceBlueprint"] = "units/UAA0303/UAA0303_unit.bp",
            ["sourceBlueprintSha256"] = "be489b6ab5bde1ef6951fa492d58a2a00ac22b5ad75ca899a3061a59830e38e6",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "ANTIAIR",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "HIGHALTAIR",
                [6] = "MOBILE",
                [7] = "OVERLAYANTIAIR",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "TECH3",
                [12] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 20,
            ["sourceId"] = "UAA0303",
            ["sourceKLift"] = 3,
            ["sourceKLiftDamping"] = 2.5,
            ["sourceLiftFactor"] = 7,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca3201",
            ["weapons"] = {
                [1] = {
                    ["label"] = "AutoCannon1",
                    ["muzzleSalvoSize"] = 3,
                    ["projectilesPerOnFire"] = 3,
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
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAAAutocannonQuantum01/AAAAutocannonQuantum01_proj.bp",
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
        ["scoFieldFixPrefabCompletion"] = "1.0.1",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15,
                ["z"] = -0.2,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1.1,
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
            ["y"] = 0.15,
            ["z"] = -0.2,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 0.3,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2500,
            ["regen"] = 0,
            ["value"] = 2500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 3000,
        ["cost"] = {
            ["alloys"] = 400,
            ["energy"] = 40000,
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
        ["displayName"] = "Corona",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Corona",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uca3201",
        ["unitTypeName"] = "Corona",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 25,
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
        ["minSpeed"] = 8,
        ["orbitRange"] = 5.092958178940651,
        ["orbitSpeed"] = 8,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 5.092958178940651,
                    ["speed"] = 8,
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
        ["preferredAltitude"] = 20,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 25,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
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
        [1] = "AIR",
        [2] = "ANTI_AIR",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CHOSEN",
        [5] = "MOBILE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_AIR",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ANTIAIR",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_HIGHALTAIR",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_OVERLAYANTIAIR",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_TECH3",
        [19] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca3201/LOD0/uca3201.sananimation",
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
                    ["y"] = 0.22499999999999998,
                    ["z"] = -0.4,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.204,
                    ["z"] = -0.020000000000000018,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.23399999999999999,
                    ["z"] = -0.04000000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.276,
                    ["z"] = -0.4,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.27,
                    ["z"] = -0.020000000000000018,
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
                ["y"] = 0.15,
                ["z"] = -0.2,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1.1,
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
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 120,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Muzzle",
                    ["yawMax"] = 55,
                    ["yawMin"] = -55,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 135,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca3201/muzzle_autocannon1.sanvfx",
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
                        [1] = "Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Muzzle"] = {
                    ["aimController"] = "Muzzle",
                },
            },
            ["projectileLifetime"] = 0.3125,
            ["projectileTemplate"] = "psf0044",
            ["rangeMax"] = 30,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "09e60f83c02e3f27795f99dfecbab972bfd8e8a273f1e79488869d905dbaf404",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AutoCannon1",
                ["sourceProjectile"] = "/projectiles/AAAAutocannonQuantum01/AAAAutocannonQuantum01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "AutoCannon1",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AutoCannon1",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 200,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
