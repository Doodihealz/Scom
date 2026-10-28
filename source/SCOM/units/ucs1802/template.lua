-- ucs1802: Shard
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 32,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 2,
                    ["z"] = 6,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAS0102/UAS0102_unit.bp",
            ["sourceBlueprintSha256"] = "fb4a21dbf21dcb31c1cf2b8d4e7488d5c5d62a55febf8e97a3eda9d9ce9183e4",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ANTIAIR",
                [3] = "BUILTBYEXPERIMENTALSUB",
                [4] = "BUILTBYTIER1FACTORY",
                [5] = "BUILTBYTIER2FACTORY",
                [6] = "BUILTBYTIER3FACTORY",
                [7] = "LIGHTBOAT",
                [8] = "MOBILE",
                [9] = "NAVAL",
                [10] = "OVERLAYANTIAIR",
                [11] = "PRODUCTSC1",
                [12] = "RECLAIMABLE",
                [13] = "SELECTABLE",
                [14] = "TECH1",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAS0102",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 8,
            ["sourceMotionType"] = "RULEUMT_Water",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs1802",
            ["weapons"] = {
                [1] = {
                    ["label"] = "MainGun",
                    ["muzzleSalvoSize"] = 3,
                    ["projectilesPerOnFire"] = 3,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle01",
                            },
                            ["rackBone"] = "Turret_Barrel",
                        },
                    },
                    ["rateOfFire"] = 1.6,
                    ["reloadTime"] = 0.625,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAASonicPulse01/AAASonicPulse01_proj.bp",
                },
            },
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "UAS0102",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 26.66666603088379,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 26.66666603088379,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 26.66666603088379,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.07500000000000001,
                ["z"] = 0.1,
            },
            ["size"] = {
                ["x"] = 0.36,
                ["y"] = 0.9,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod3110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.07500000000000001,
            ["z"] = 0.1,
        },
        ["collisionSize"] = {
            ["x"] = 0.65,
            ["y"] = 0.65,
            ["z"] = 1.65,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 750,
            ["regen"] = 0,
            ["value"] = 750,
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 120,
            ["energy"] = 1200,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortNavalUnit",
        },
        ["displayName"] = "Shard",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Shard",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucs1802",
        ["unitTypeName"] = "Shard",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 8,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 8,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 100,
        ["sortOrder"] = 1,
        ["speed"] = 8,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
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
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CHOSEN",
        [6] = "MOBILE",
        [7] = "NAVAL",
        [8] = "TECH1",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_ANTIAIR",
        [12] = "SCFA_BUILTBYEXPERIMENTALSUB",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_LIGHTBOAT",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_NAVAL",
        [19] = "SCFA_OVERLAYANTIAIR",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1802/LOD0/ucs1802.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1802/LOD0/ucs1802.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1802/LOD0/ucs1802.sananimation",
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucs1802/LOD0/ucs1802.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["sanAnimationPath"] = "Units/ucs1802/LOD0/ucs1802.sananimation",
            },
            ["source_animadeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["sanAnimationPath"] = "Units/ucs1802/LOD0/ucs1802.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucs1802/LOD0/ucs1802.sananimation",
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
                    ["audioName"] = "chosen_unit_death_small",
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
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.23750000000000002,
                    ["z"] = -0.23,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.192,
                    ["z"] = 0.397,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13,
                    ["y"] = 0.257,
                    ["z"] = 0.364,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.34800000000000003,
                    ["z"] = -0.23,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.335,
                    ["z"] = 0.397,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 73,
            ["lod1distance"] = 190,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.07500000000000001,
                ["z"] = 0.1,
            },
            ["size"] = {
                ["x"] = 0.36,
                ["y"] = 0.9,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.5,
                    ["defaultPitchAdjustment"] = 10,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 190,
                    ["pitchMin"] = -170,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 7,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs1802/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
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
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
            },
            ["projectileLifetime"] = 1.3333333333333333,
            ["projectileTemplate"] = "psf0047",
            ["rangeMax"] = 48,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.625,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "cda3010d76ab10acebc27d20e84802d5f6ec077870e5be3a2ea8eba21bb9bf9e",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/AAASonicPulse01/AAASonicPulse01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "MainGun",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
