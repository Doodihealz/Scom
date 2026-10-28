-- ugl2101: Hoplite
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0.0004610469937324525,
                [2] = 0.9272494606561716,
                [3] = -0.0036560446508741387,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["foldDuration"] = 2.5,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "DRL0204",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 173488,
                ["entry"] = "units/DRL0204/DRL0204_lod0.scm",
                ["sha256"] = "6299a15eac24dd539e115843e420390b98d76c731ac695fdbe35fe52b85799ce",
            },
            ["unfoldDuration"] = 3,
        },
        ["scoFieldFixCybran"] = "1.0.4",
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "R_Leg01_B03",
                    ["contactOffset"] = {
                        ["x"] = 0.00032849091261763497,
                        ["y"] = -0.21568950351969235,
                        ["z"] = 0.153334508655672,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.00013832923347615385,
                        ["y"] = 0.00015662048534036948,
                        ["z"] = 0.9999999781675232,
                    },
                    ["length"] = 0.015187621116638184,
                    ["liftHeight"] = 0.07171288393796742,
                    ["minimumHeight"] = -0.024886199920586605,
                    ["plantHeight"] = 0.020113800079413394,
                    ["right"] = {
                        ["x"] = 0.9999999464229542,
                        ["y"] = 0.0002967018150684361,
                        ["z"] = 0.00013828275950165996,
                    },
                    ["width"] = 0.03464891016483307,
                },
                [2] = {
                    ["boneName"] = "R_Leg02_B03",
                    ["contactOffset"] = {
                        ["x"] = 0.00032527158080897234,
                        ["y"] = -0.21568324868716618,
                        ["z"] = 0.15333264891150256,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.8607733777713926,
                        ["y"] = -7.315803317586005e-07,
                        ["z"] = -0.5089884007710712,
                    },
                    ["length"] = 0.03755068778991699,
                    ["liftHeight"] = 0.11747251729561642,
                    ["minimumHeight"] = -0.022545208676798892,
                    ["plantHeight"] = 0.022454791323201106,
                    ["right"] = {
                        ["x"] = -0.5089884007708807,
                        ["y"] = -4.404369033536031e-07,
                        ["z"] = 0.8607733777717035,
                    },
                    ["width"] = 0.030705511569976807,
                },
                [3] = {
                    ["boneName"] = "B_Leg01_B03",
                    ["contactOffset"] = {
                        ["x"] = 0.000324652369285612,
                        ["y"] = -0.21568421272561775,
                        ["z"] = 0.15333260628614653,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.0021303556417577962,
                        ["y"] = -4.796134195994365e-07,
                        ["z"] = -0.9999977307897301,
                    },
                    ["length"] = 0.015259981155395508,
                    ["liftHeight"] = 0.07093201174728045,
                    ["minimumHeight"] = -0.018200080847091488,
                    ["plantHeight"] = 0.02679991915290851,
                    ["right"] = {
                        ["x"] = -0.9999977290749456,
                        ["y"] = 5.856353278657297e-05,
                        ["z"] = -0.002130355666192607,
                    },
                    ["width"] = 0.03467809781432152,
                },
                [4] = {
                    ["boneName"] = "L_Leg02_B03",
                    ["contactOffset"] = {
                        ["x"] = 0.00032626412266088464,
                        ["y"] = -0.21568501060350825,
                        ["z"] = 0.15333304788678537,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.8722443298095105,
                        ["y"] = 5.959755308745691e-05,
                        ["z"] = -0.4890703687234488,
                    },
                    ["length"] = 0.037646979093551636,
                    ["liftHeight"] = 0.11641990335747429,
                    ["minimumHeight"] = -0.024559985717066732,
                    ["plantHeight"] = 0.020440014282933266,
                    ["right"] = {
                        ["x"] = -0.48907036450713237,
                        ["y"] = -7.285100298567586e-05,
                        ["z"] = -0.8722443311673586,
                    },
                    ["width"] = 0.030188143253326416,
                },
                [5] = {
                    ["boneName"] = "L_Leg01_B03",
                    ["contactOffset"] = {
                        ["x"] = 0.0003215614137356826,
                        ["y"] = -0.2156889916127925,
                        ["z"] = 0.15333280345736489,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.00017109721597547586,
                        ["y"] = 1.163252394416604e-06,
                        ["z"] = 0.9999999853621947,
                    },
                    ["length"] = 0.015192210674285889,
                    ["liftHeight"] = 0.07245971444350396,
                    ["minimumHeight"] = -0.023606415792503832,
                    ["plantHeight"] = 0.021393584207496166,
                    ["right"] = {
                        ["x"] = 0.999999928536681,
                        ["y"] = -0.0003371238839891789,
                        ["z"] = -0.00017109681409261754,
                    },
                    ["width"] = 0.03464925289154053,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ugl2101/LOD0/ugl2101_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ugl2101",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scomRestoredAnimations"] = {
            ["assetSha256"] = "d9ba3fd6f4a5a6da3bea2184ee3beee7e6197052a3d8c32373e2ec60777e5d4e",
            ["runtimeRate"] = 1,
            ["sourceDeathRateRandomization"] = false,
            ["sourceId"] = "DRL0204",
            ["transportEventBinding"] = "source cargo load/unload lifecycle",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.4,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.85,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1325",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.4,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.45,
            ["y"] = 0.8,
            ["z"] = 0.9,
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
        ["buildTime"] = 1000,
        ["cost"] = {
            ["alloys"] = 200,
            ["energy"] = 1000,
        },
    },
    ["footprint"] = {
        ["x"] = 0.45,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardLandUnit",
        },
        ["displayName"] = "Hoplite",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_direct.png",
        ["iconUIBuildSortPriority"] = 20,
        ["iconUIType"] = "land",
        ["name"] = "Hoplite",
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
            ["Land"] = 289.8,
            ["WaterSurface"] = 325.3,
        },
        ["tpId"] = "ugl2101",
        ["unitTypeName"] = "GuardT2Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 3.5,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 3.6,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 3,
        ["speed"] = 3.6,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.972972972972973,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 37,
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
        [1] = "ANTI_SURFACE",
        [2] = "BOT",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "DIRECT_FIRE",
        [6] = "GUARD",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH2",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BOT",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_CYBRAN",
        [15] = "SCFA_DIRECTFIRE",
        [16] = "SCFA_LAND",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_OVERLAYDIRECTFIRE",
        [19] = "SCFA_PRODUCTDL",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_TECH2",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
            },
            ["death"] = {
                ["clipName"] = "AnimDeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
            },
            ["death01"] = {
                ["clipName"] = "AnimDeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
            },
            ["death02"] = {
                ["clipName"] = "AnimDeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
            },
            ["fold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.972972972972973,
                ["clipName"] = "AnimWalk01",
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["unfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugl2101/LOD0/ugl2101.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.081,
                    ["y"] = 0.6000000000000001,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.099,
                    ["y"] = 0.544,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09000000000000001,
                    ["y"] = 0.6240000000000001,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.081,
                    ["y"] = 0.736,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.099,
                    ["y"] = 0.7200000000000001,
                    ["z"] = 0.162,
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
                ["y"] = 0.4,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.85,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 100,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 14,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 50,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom3100",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 60,
            ["damageFriendly"] = false,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugl2101/muzzle_rocketbackpack.sanvfx",
            },
            ["firingRandomness"] = 0,
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
                        [1] = "Turret_Muzzle_01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Turret_Muzzle_01"] = {
                    ["aimController"] = "Turret_Muzzle_01",
                },
                ["Turret_Muzzle_02"] = {
                    ["aimController"] = "Turret_Muzzle_01",
                },
                ["Turret_Muzzle_03"] = {
                    ["aimController"] = "Turret_Muzzle_01",
                },
            },
            ["projectileLifetime"] = 4.25,
            ["projectileTemplate"] = "psf0095",
            ["rangeMax"] = 37,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "6e29a113ca2678aed23f2f0cc9d69418f259eccd69244efb4539d9dfc2f0b4e5",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "RocketBackpack",
                ["sourceProjectile"] = "/projectiles/CDFRocketIridium02/CDFRocketIridium02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "RocketBackpack",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
