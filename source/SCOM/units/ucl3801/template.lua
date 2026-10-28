-- ucl3801: Sprite Striker
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faAnimationClosureWeaponDeploy"] = {
            ["authoredDurationSeconds"] = 1,
            ["authoredRate"] = 1,
            ["deployAnimationKey"] = "fa_deploy",
            ["mapping"] = "XAL0305 -> ucl3801",
            ["packedAnimationKey"] = "fa_packed",
            ["repackTimeoutSeconds"] = 0,
            ["sourceAnimation"] = "units/XAL0305/XAL0305_asetup.sca",
            ["sourceAnimationSha256"] = "15f53413216527c24d86e1586cd9941e8840379c9f4733cae6b598e5a9a52483",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprintSha256"] = "b5ba4a2ba84fabd475a6ac44a9bfec9b5e00bb471e870a4610ca291be8bd0deb",
            ["sourceModelSha256"] = "ea4d6e409d5fd40254b943ef5422c98a368cacf9b9a92a939f05cb4a0a9abd4e",
            ["sourceScriptSha256"] = "fab3bee322ff591be54677bbe27c6a3c978d0febe940e4e7bdfe5a3c62ae9dac",
            ["sourceWeaponUnpackLocksMotion"] = true,
            ["sourceWeaponUnpacks"] = true,
            ["transitionSeconds"] = 1,
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 26,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.8,
                    ["z"] = 0.6,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XAL0305/XAL0305_unit.bp",
            ["sourceBlueprintSha256"] = "b5ba4a2ba84fabd475a6ac44a9bfec9b5e00bb471e870a4610ca291be8bd0deb",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BOT",
                [3] = "BUILTBYTIER3FACTORY",
                [4] = "DIRECTFIRE",
                [5] = "LAND",
                [6] = "MOBILE",
                [7] = "OVERLAYDIRECTFIRE",
                [8] = "PRODUCTFA",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "TECH3",
                [12] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "XAL0305",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 3,
            ["sourceMotionType"] = "RULEUMT_Land",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl3801",
            ["weapons"] = {
                [1] = {
                    ["label"] = "MainGun",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle",
                            },
                            ["rackBone"] = "Turret_Barrel",
                        },
                    },
                    ["rateOfFire"] = 0.1,
                    ["reloadTime"] = 10,
                    ["sourceCategory"] = "Direct Fire",
                    ["sourceProjectile"] = "/projectiles/ADFHeavyDisruptorCannon01/ADFHeavyDisruptorCannon01_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 6.54464401304722e-05,
                [2] = 1.155323410940124,
                [3] = -0.007599608710581366,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["foldDuration"] = 2.1666667461395264,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XAL0305",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 179172,
                ["entry"] = "units/XAL0305/XAL0305_lod0.scm",
                ["sha256"] = "ea4d6e409d5fd40254b943ef5422c98a368cacf9b9a92a939f05cb4a0a9abd4e",
            },
            ["unfoldDuration"] = 2.1666667461395264,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "lleg_R_F_01",
                    ["contactOffset"] = {
                        ["x"] = -7.747159480024635e-05,
                        ["y"] = -0.7787920530777936,
                        ["z"] = -0.01154147566810837,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.7064921416806274,
                        ["y"] = 0.0036496489838496126,
                        ["z"] = 0.7077114763841372,
                    },
                    ["length"] = 0.028674662113189697,
                    ["liftHeight"] = 0.11497538094189988,
                    ["minimumHeight"] = -0.021731748090257103,
                    ["plantHeight"] = 0.023268251909742896,
                    ["right"] = {
                        ["x"] = 0.707718397021678,
                        ["y"] = -0.006295865766567198,
                        ["z"] = -0.7064665827845757,
                    },
                    ["width"] = 0.028805285692214966,
                },
                [2] = {
                    ["boneName"] = "lleg_L_F_01",
                    ["contactOffset"] = {
                        ["x"] = -2.528918128026636e-05,
                        ["y"] = -0.7788611292750373,
                        ["z"] = -0.011736281123326475,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.707106661977164,
                        ["y"] = -4.6530659252448555e-07,
                        ["z"] = 0.7071069003957579,
                    },
                    ["length"] = 0.0284603089094162,
                    ["liftHeight"] = 0.11507132837686965,
                    ["minimumHeight"] = -0.022216325235517836,
                    ["plantHeight"] = 0.022783674764482162,
                    ["right"] = {
                        ["x"] = 0.7071069003958231,
                        ["y"] = 3.306835224394734e-08,
                        ["z"] = 0.707106661977251,
                    },
                    ["width"] = 0.028468161821365356,
                },
                [3] = {
                    ["boneName"] = "lleg_L_F_02",
                    ["contactOffset"] = {
                        ["x"] = -9.937103984980836e-05,
                        ["y"] = -0.7788890980579144,
                        ["z"] = -0.011752657701911584,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.7063282213498506,
                        ["y"] = 0.002296606458725215,
                        ["z"] = -0.7078807592550669,
                    },
                    ["length"] = 0.02834564447402954,
                    ["liftHeight"] = 0.11539207668071336,
                    ["minimumHeight"] = -0.021865557265889984,
                    ["plantHeight"] = 0.023134442734110014,
                    ["right"] = {
                        ["x"] = -0.7078795030667528,
                        ["y"] = 0.0014600717250405387,
                        ["z"] = 0.7063317048869636,
                    },
                    ["width"] = 0.02853626012802124,
                },
                [4] = {
                    ["boneName"] = "lleg_R_F_03",
                    ["contactOffset"] = {
                        ["x"] = 9.329782795887073e-05,
                        ["y"] = -0.7788380367730864,
                        ["z"] = -0.011598402535885233,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.7061021653129697,
                        ["y"] = -0.00048732345346626975,
                        ["z"] = -0.7081098040955143,
                    },
                    ["length"] = 0.0284939706325531,
                    ["liftHeight"] = 0.11545618626142164,
                    ["minimumHeight"] = -0.021434048425127278,
                    ["plantHeight"] = 0.02356595157487272,
                    ["right"] = {
                        ["x"] = -0.7080970258087775,
                        ["y"] = -0.006532793230609887,
                        ["z"] = -0.7060849273659434,
                    },
                    ["width"] = 0.028823763132095337,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ucl3801/LOD0/ucl3801_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ucl3801",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "XAL0305",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 3,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.25,
                    ["rateMin"] = 0.75,
                    ["weight"] = 1,
                },
                [2] = {
                    ["durationSeconds"] = 3,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1.25,
                    ["rateMin"] = 0.75,
                    ["weight"] = 1,
                },
                [3] = {
                    ["durationSeconds"] = 4,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1.25,
                    ["rateMin"] = 0.75,
                    ["weight"] = 1,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1110",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.5,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 1,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 450,
            ["regen"] = 0,
            ["value"] = 450,
        },
    },
    ["economy"] = {
        ["buildTime"] = 4800,
        ["cost"] = {
            ["alloys"] = 800,
            ["energy"] = 8000,
        },
    },
    ["footprint"] = {
        ["x"] = 0.8,
        ["y"] = 0.6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Sprite Striker",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Sprite Striker",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucl3801",
        ["unitTypeName"] = "Sprite Striker",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 3,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 3,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 3,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.46875,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 70,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
        },
    },
    ["tags"] = {
        [1] = "BOT",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "DIRECT_FIRE",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "TECH3",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BOT",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_DIRECTFIRE",
        [13] = "SCFA_LAND",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYDIRECTFIRE",
        [16] = "SCFA_PRODUCTFA",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_TECH3",
        [20] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimCargoUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["fa_deploy"] = {
                ["clipName"] = "AnimAsetup",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["fa_packed"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.46875,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["source_animadeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["source_animasetup"] = {
                ["clipName"] = "AnimAsetup",
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl3801/LOD0/ucl3801.sananimation",
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
                    ["audioName"] = "EDA_UnitExplosions_Random",
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
                    ["x"] = 0.144,
                    ["y"] = 0.75,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.6799999999999999,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.78,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.9199999999999999,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.9,
                    ["z"] = 0.108,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 65,
            ["lod1distance"] = 171,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 10,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 70,
                    ["pitchMin"] = -50,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 120,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 75,
                },
            },
            ["damage"] = 1300,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl3801/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Water",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 0.6708333333333333,
            ["projectileTemplate"] = "psf0057",
            ["rangeMax"] = 70,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 10,
            ["scoFaAnimationClosureDeploy"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "8064e8a7c73fe5fa26fba4defd896e159e7cbef8c74a38a14ecf8683a3f7bca6",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/ADFHeavyDisruptorCannon01/ADFHeavyDisruptorCannon01_proj.bp",
            },
            ["scoSourceCategory"] = "Direct Fire",
            ["scoSourceLabel"] = "MainGun",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
