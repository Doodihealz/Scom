-- usl1701: Selen
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -0.0014214859008789063,
                [2] = 0.648132750979626,
                [3] = 0.004070301786998159,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["foldDuration"] = 2.5,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0101",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 52904,
                ["entry"] = "units/XSL0101/XSL0101_lod0.scm",
                ["sha256"] = "5df75ae9eac2b1d24a869e72d0c875d5d228cc1073a5d804dbbe2da2504c4fdb",
            },
            ["unfoldDuration"] = 2.1666667461395264,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Leg_Lower_R",
                    ["contactOffset"] = {
                        ["x"] = 0.0009773011803626969,
                        ["y"] = -0.3548238814964544,
                        ["z"] = -0.05387024816856151,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163514e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.031934004015056416,
                    ["liftHeight"] = 0.17530498860694368,
                    ["minimumHeight"] = -0.016940012756879924,
                    ["plantHeight"] = 0.028059987243120074,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.006604790687561035,
                },
                [2] = {
                    ["boneName"] = "Leg_Lower_L",
                    ["contactOffset"] = {
                        ["x"] = -0.0009773049056529953,
                        ["y"] = -0.3548238813307772,
                        ["z"] = -0.05248044691371629,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163514e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.031934004509821534,
                    ["liftHeight"] = 0.17482794489324802,
                    ["minimumHeight"] = -0.016726974560256153,
                    ["plantHeight"] = 0.028273025439743846,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.006604798138141632,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/usl1701/LOD0/usl1701_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "usl1701",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.325,
                ["z"] = 0.05,
            },
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1.1666666269302368,
                ["key"] = "source_animadeath01",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
            [2] = {
                ["durationSeconds"] = 1.1666666269302368,
                ["key"] = "source_animadeath02",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
            [3] = {
                ["durationSeconds"] = 1.1666666269302368,
                ["key"] = "source_animadeath03",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1411",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.325,
            ["z"] = 0.05,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.7,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 35,
            ["regen"] = 0,
            ["value"] = 35,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80,
        ["cost"] = {
            ["alloys"] = 20,
            ["energy"] = 80,
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
        ["displayName"] = "Selen",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "intel",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_intel.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "amphibious",
        ["name"] = "Selen",
        ["orders"] = {
            ["Assist"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usl1701",
        ["unitTypeName"] = "UnknownT1LandScout",
    },
    ["intel"] = {
        ["radarRadius"] = 40,
        ["visionRadius"] = 24,
    },
    ["movement"] = {
        ["acceleration"] = 4,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 4,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 80,
        ["sortOrder"] = 2,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 4,
        },
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 40,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_FACTORY",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "INTEL",
        [5] = "MOBILE",
        [6] = "RADAR",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER1FACTORY",
        [9] = "SCFA_BUILTBYTIER2FACTORY",
        [10] = "SCFA_BUILTBYTIER3FACTORY",
        [11] = "SCFA_COUNTERINTELLIGENCE",
        [12] = "SCFA_DIRECTFIRE",
        [13] = "SCFA_LAND",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYDIRECTFIRE",
        [16] = "SCFA_OVERLAYRADAR",
        [17] = "SCFA_PRODUCTFA",
        [18] = "SCFA_RADAR",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SCOUT",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SERAPHIM",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_VISIBLETORECON",
        [25] = "SCOUT",
        [26] = "SERAPHIM",
        [27] = "TECH1",
        [28] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 4,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
            },
            ["source_animadeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
            },
            ["source_animunfold"] = {
                ["clipName"] = "AnimUnfold",
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl1701/LOD0/usl1701.sananimation",
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
                    ["y"] = 0.5,
                    ["z"] = -0.06999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.451,
                    ["z"] = 0.158,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.521,
                    ["z"] = 0.14600000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.619,
                    ["z"] = -0.06999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.605,
                    ["z"] = 0.158,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 65,
            ["lod1distance"] = 169,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.325,
                ["z"] = 0.05,
            },
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
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
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 4,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl1701/muzzle_laserturret.sanvfx",
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
                        [1] = "Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0132",
            ["rangeMax"] = 16,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "50b0a9c81d599048b2cd057f19f9085b51330086e528fc718f3d025bce817020",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LaserTurret",
                ["sourceProjectile"] = "/projectiles/SDFPhasicAutogun01/SDFPhasicAutogun01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LaserTurret",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
