-- usl3101: Suthanus
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faAnimationClosureWeaponDeploy"] = {
            ["authoredDurationSeconds"] = 1,
            ["authoredRate"] = 1,
            ["deployAnimationKey"] = "fa_deploy",
            ["mapping"] = "XSL0304 -> usl3101",
            ["packedAnimationKey"] = "fa_packed",
            ["repackTimeoutSeconds"] = 0,
            ["sourceAnimation"] = "units/XSL0304/XSL0304_attack01.sca",
            ["sourceAnimationSha256"] = "65c295a71f8e2028f3b2520b153e1a12687490dc0b0090d6d2dc15984cfd227c",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprintSha256"] = "2f8dd478914dfbe90e98952a2a2cccbbc936f597833becab205c5f5a01aebca5",
            ["sourceModelSha256"] = "24bd6effa460d7df197745d27089b7f5338ec3df52425302a1c915d2d898c4e2",
            ["sourceScriptSha256"] = "65d8633cb939e447d7c674c35384ce0da908d04d92a21c1b47301e48944e9c90",
            ["sourceWeaponUnpackLocksMotion"] = true,
            ["sourceWeaponUnpacks"] = true,
            ["transitionSeconds"] = 1,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0.0023302149027585985,
                [2] = 0.845726544659104,
                [3] = 0.021660280016260657,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["foldDuration"] = 2.5,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0304",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 132428,
                ["entry"] = "units/XSL0304/XSL0304_lod0.scm",
                ["sha256"] = "24bd6effa460d7df197745d27089b7f5338ec3df52425302a1c915d2d898c4e2",
            },
            ["unfoldDuration"] = 2.5,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Back_Left_Leg_B02",
                    ["contactOffset"] = {
                        ["x"] = -0.33166600034889054,
                        ["y"] = -0.30476715494567264,
                        ["z"] = -0.001280817277021451,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 1.341105206331683e-07,
                        ["y"] = 0.9999999999997243,
                        ["z"] = -7.301569382445194e-07,
                    },
                    ["length"] = 0.07296276092529297,
                    ["liftHeight"] = 0.04729030783879038,
                    ["minimumHeight"] = -0.041066979496223094,
                    ["plantHeight"] = 0.0039330205037769045,
                    ["right"] = {
                        ["x"] = 1.4901168299275014e-08,
                        ["y"] = 7.301569364126514e-07,
                        ["z"] = 0.9999999999997331,
                    },
                    ["width"] = 0.03182250261306763,
                },
                [2] = {
                    ["boneName"] = "Back_Right_Leg_B02",
                    ["contactOffset"] = {
                        ["x"] = -0.33166624617930346,
                        ["y"] = 0.3047675162553788,
                        ["z"] = -0.0012852104941220022,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = -1,
                        ["z"] = 0,
                    },
                    ["length"] = 0.07296273112297058,
                    ["liftHeight"] = 0.03491251701769684,
                    ["minimumHeight"] = -0.046015038882878084,
                    ["plantHeight"] = -0.001015038882878086,
                    ["right"] = {
                        ["x"] = 2.384185791015625e-07,
                        ["y"] = 0,
                        ["z"] = -0.9999999999999716,
                    },
                    ["width"] = 0.03182244300842285,
                },
                [3] = {
                    ["boneName"] = "Front_Left_Leg_B02",
                    ["contactOffset"] = {
                        ["x"] = 0.00020830012139927412,
                        ["y"] = -0.3817024360571374,
                        ["z"] = 0.09589414096243054,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -1.523850473295985e-13,
                        ["y"] = 7.152557373044872e-07,
                        ["z"] = 0.9999999999997442,
                    },
                    ["length"] = 0.07138800621032715,
                    ["liftHeight"] = 0.08429898948910504,
                    ["minimumHeight"] = -0.037487957624915774,
                    ["plantHeight"] = 0.007512042375084224,
                    ["right"] = {
                        ["x"] = 0.9999999999999741,
                        ["y"] = 2.2741734539976235e-07,
                        ["z"] = -1.0276513730144295e-14,
                    },
                    ["width"] = 0.04088035225868225,
                },
                [4] = {
                    ["boneName"] = "Front_Right_Leg_B02",
                    ["contactOffset"] = {
                        ["x"] = -0.00020854080240284567,
                        ["y"] = -0.3817024569736718,
                        ["z"] = 0.09589414115810635,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -8.331954716602822e-15,
                        ["y"] = 1.1920930376163493e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.07138800621032715,
                    ["liftHeight"] = 0.08330654182563942,
                    ["minimumHeight"] = -0.03931029495905694,
                    ["plantHeight"] = 0.005689705040943058,
                    ["right"] = {
                        ["x"] = 0.9999999999999988,
                        ["y"] = 5.038002370838521e-08,
                        ["z"] = 2.326187166831565e-15,
                    },
                    ["width"] = 0.04088038206100464,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/usl3101/LOD0/usl3101_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "usl3101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.4,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 1,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 2,
                ["key"] = "source_animadeath01",
                ["rateMaxTenths"] = 15,
                ["rateMinTenths"] = 5,
                ["weight"] = 100,
            },
            [2] = {
                ["durationSeconds"] = 2,
                ["key"] = "source_animadeath02",
                ["rateMaxTenths"] = 15,
                ["rateMinTenths"] = 5,
                ["weight"] = 100,
            },
            [3] = {
                ["durationSeconds"] = 2.6666667461395264,
                ["key"] = "source_animadeath03",
                ["rateMaxTenths"] = 15,
                ["rateMinTenths"] = 5,
                ["weight"] = 100,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1430",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1130",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.4,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.8,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 925,
            ["regen"] = 0,
            ["value"] = 925,
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
        ["x"] = 0.7,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Suthanus",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "indirect",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_land1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "amphibious",
        ["name"] = "Suthanus",
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
            ["Land"] = 489.9,
            ["WaterSurface"] = 591,
        },
        ["tpId"] = "usl3101",
        ["unitTypeName"] = "UnknownT3MobileArty",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 2.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 75,
        ["sortOrder"] = 3,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.892857142857143,
        },
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 90,
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
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "INDIRECT_FIRE",
        [4] = "MOBILE",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_BUILTBYTIER3FACTORY",
        [7] = "SCFA_INDIRECTFIRE",
        [8] = "SCFA_LAND",
        [9] = "SCFA_MOBILE",
        [10] = "SCFA_OVERLAYINDIRECTFIRE",
        [11] = "SCFA_PRODUCTFA",
        [12] = "SCFA_RECLAIM",
        [13] = "SCFA_RECLAIMABLE",
        [14] = "SCFA_REPAIR",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SERAPHIM",
        [17] = "SCFA_SHOWATTACKRETICLE",
        [18] = "SCFA_TECH3",
        [19] = "SCFA_VISIBLETORECON",
        [20] = "SERAPHIM",
        [21] = "TECH3",
        [22] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["fa_deploy"] = {
                ["clipName"] = "AnimAttack01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["fa_packed"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.892857142857143,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["source_animadeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["source_animattack01"] = {
                ["clipName"] = "AnimAttack01",
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["source_animunfold"] = {
                ["clipName"] = "AnimUnfold",
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl3101/LOD0/usl3101.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
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
                    ["particleName"] = "VFX/Death/vcd1301_death_land_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.6000000000000001,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.544,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.6240000000000001,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.736,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.7200000000000001,
                    ["z"] = 0.162,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 69,
            ["lod1distance"] = 179,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.4,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 1,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Barrel_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 85,
                    ["pitchMin"] = -10,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 22,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 30,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom1230",
                },
            },
            ["damage"] = 700,
            ["damageRadius"] = 6,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl3101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 2,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Barrel_Muzzle",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Barrel_Muzzle"] = {
                    ["aimController"] = "Turret_Barrel_Muzzle",
                },
            },
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "psf0142",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 10,
            ["scoFaAnimationClosureDeploy"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "e35f83d4c5e2c02e0f1c29c2dc0fe8b7d79d1554b79a10ad250ba0d2afa40e51",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/SIFSuthanusArtilleryShell01/SIFSuthanusArtilleryShell01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
