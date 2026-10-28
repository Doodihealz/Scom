-- usl1201: Ia-istle
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.4906609057544329,
                [3] = -0.03929887704122506,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["foldDuration"] = 0.3333333432674408,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0104",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 66183,
                ["entry"] = "units/XSL0104/XSL0104_lod0.scm",
                ["sha256"] = "789bb88f6b367b9a627f2db9865773a385693c3a567efb0df3a1fba25a6bd690",
            },
            ["unfoldDuration"] = 0.3333333432674408,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Leg_Lower_01",
                    ["contactOffset"] = {
                        ["x"] = 0.16514411449432373,
                        ["y"] = -0.27207140848498645,
                        ["z"] = 0.20717762062890158,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163512e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.012995690107345581,
                    ["liftHeight"] = 0.037341600604704386,
                    ["minimumHeight"] = -0.021773247310428928,
                    ["plantHeight"] = 0.01734160060470439,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.015593171119689941,
                },
                [2] = {
                    ["boneName"] = "Leg_Lower_02",
                    ["contactOffset"] = {
                        ["x"] = 0.1651820158958435,
                        ["y"] = -0.27207146236242336,
                        ["z"] = -0.2071604888643505,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163512e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.012995630502700806,
                    ["liftHeight"] = 0.03726067424207268,
                    ["minimumHeight"] = -0.021802996176175232,
                    ["plantHeight"] = 0.017260674242072685,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.015593171119689941,
                },
                [3] = {
                    ["boneName"] = "Leg_Lower_03",
                    ["contactOffset"] = {
                        ["x"] = -0.16514417588710784,
                        ["y"] = -0.27207139530720154,
                        ["z"] = -0.2071775584425293,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163512e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.012995630502700806,
                    ["liftHeight"] = 0.03729712006994213,
                    ["minimumHeight"] = -0.021764591275863637,
                    ["plantHeight"] = 0.017297120069942128,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.015593081712722778,
                },
                [4] = {
                    ["boneName"] = "Leg_Lower_04",
                    ["contactOffset"] = {
                        ["x"] = -0.16449476182460784,
                        ["y"] = -0.27207137573968476,
                        ["z"] = 0.2075066001210812,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163512e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.012995690107345581,
                    ["liftHeight"] = 0.03733747206790399,
                    ["minimumHeight"] = -0.02177544155898556,
                    ["plantHeight"] = 0.017337472067903995,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.015593081712722778,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/usl1201/LOD0/usl1201_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "usl1201",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.2,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.45,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1.7333333492279053,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 15,
                ["rateMinTenths"] = 5,
                ["weight"] = 100,
            },
            [2] = {
                ["durationSeconds"] = 2.1666667461395264,
                ["key"] = "source_animadeath02",
                ["rateMaxTenths"] = 15,
                ["rateMinTenths"] = 5,
                ["weight"] = 100,
            },
            [3] = {
                ["durationSeconds"] = 2.1666667461395264,
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
            ["name"] = "aclu1410",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.2,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.4,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 200,
            ["regen"] = 0,
            ["value"] = 200,
        },
    },
    ["economy"] = {
        ["buildTime"] = 140,
        ["cost"] = {
            ["alloys"] = 28,
            ["energy"] = 140,
        },
    },
    ["footprint"] = {
        ["x"] = 0.6,
        ["y"] = 0.6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Ia-istle",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "aa",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_antiAir.png",
        ["iconUIBuildSortPriority"] = 50,
        ["iconUIType"] = "amphibious",
        ["name"] = "Ia-istle",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 74.6,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usl1201",
        ["unitTypeName"] = "UnknownT1MAA",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
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
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 5,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.5,
        },
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "MOBILE",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_ANTIAIR",
        [8] = "SCFA_BUILTBYTIER1FACTORY",
        [9] = "SCFA_BUILTBYTIER2FACTORY",
        [10] = "SCFA_BUILTBYTIER3FACTORY",
        [11] = "SCFA_LAND",
        [12] = "SCFA_MOBILE",
        [13] = "SCFA_OVERLAYANTIAIR",
        [14] = "SCFA_PRODUCTFA",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SERAPHIM",
        [18] = "SCFA_TECH1",
        [19] = "SCFA_VISIBLETORECON",
        [20] = "SERAPHIM",
        [21] = "TECH1",
        [22] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimCargoUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.5,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
            },
            ["source_animadeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl1201/LOD0/usl1201.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
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
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.30000000000000004,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.272,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.31200000000000006,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.368,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.36000000000000004,
                    ["z"] = 0.108,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 172,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.2,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.45,
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
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 90,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 100,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom1111",
                },
            },
            ["damage"] = 4,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl1201/muzzle_aagun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle01",
                        [2] = "Turret_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
                ["Turret_Muzzle02"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0109",
            ["rangeMax"] = 32,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "9539620fea362f051a424ba168d0bb2efc9887e1a522037fd2a7f579f0a7c3c6",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/SAAShleoAAGatlingGun01/SAAShleoAAGatlingGun01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
