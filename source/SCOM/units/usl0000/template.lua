-- usl0000: Armored Command Unit
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["version"] = "1.0.0",
            ["projectileTemplate"] = "pocsera",
        },
        ["buildBeamBones"] = {
            [1] = "Left_Turret_Muzzle",
        },
        ["buildBeamEffectName"] = "beam1",
        ["displayWreckOnDeath"] = false,
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 1.5044687273757521e-09,
                [2] = 2.602636492111972,
                [3] = -0.018822422011279923,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = true,
            ["foldDuration"] = 2.6666667461395264,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0001",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 622248,
                ["entry"] = "units/XSL0001/XSL0001_lod0.scm",
                ["sha256"] = "36b80d97eb4493f4f312439a79648c06c88fedd718cf92508ef8dd3b1ab442ad",
            },
            ["unfoldDuration"] = 2.6666667461395264,
        },
        ["scoCommanderEnhancementBaseWeaponIndex"] = 1,
        ["scoCommanderEnhancements"] = {
            ["baseBuildCategory"] = "Tags.SERAPHIM * Tags.BUILDABLE_BY_T1_ENGINEER",
            ["capabilities"] = {
                ["chronoStun"] = false,
                ["cloak"] = "visual-aura",
                ["manualMissiles"] = true,
                ["omni"] = false,
                ["sonar"] = false,
                ["spawnPods"] = false,
                ["stealth"] = "visual-aura",
                ["teleport"] = true,
            },
            ["faction"] = "Seraphim",
            ["patchVersion"] = "1.0.4",
            ["radarPredeclared"] = false,
            ["sourceId"] = "XSL0001",
            ["version"] = "1.0.0",
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoGameplayCommanderBeam"] = "1.3.0",
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Left_Foot",
                    ["contactOffset"] = {
                        ["x"] = 0.001807285500509126,
                        ["y"] = -0.0026566264656380815,
                        ["z"] = -0.13278775066137324,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = -1.0000000000000004,
                    },
                    ["length"] = 0.5560483336448669,
                    ["liftHeight"] = 0.14671027153139424,
                    ["minimumHeight"] = -0.024206718171452906,
                    ["plantHeight"] = 0.020793281828547092,
                    ["right"] = {
                        ["x"] = -0.9999999999999889,
                        ["y"] = -1.5099580252808492e-07,
                        ["z"] = 0,
                    },
                    ["width"] = 0.3295609727501869,
                },
                [2] = {
                    ["boneName"] = "Right_Foot",
                    ["contactOffset"] = {
                        ["x"] = -0.0018000501861699103,
                        ["y"] = -0.002656897567269536,
                        ["z"] = -0.13278794516652054,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = -1.1838437402676858e-15,
                        ["y"] = 2.980232238769399e-07,
                        ["z"] = -0.9999999999999558,
                    },
                    ["length"] = 0.5560483038425446,
                    ["liftHeight"] = 0.14797252728792992,
                    ["minimumHeight"] = -0.022698694176076353,
                    ["plantHeight"] = 0.022301305823923645,
                    ["right"] = {
                        ["x"] = -0.9999999999999889,
                        ["y"] = -1.5099578831722372e-07,
                        ["z"] = -4.381640788587326e-14,
                    },
                    ["width"] = 0.3295609876513481,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/usl0000/LOD0/usl0000_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "usl0000",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 0.6,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1305",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod0000",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 2.2,
            ["z"] = 0.7,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Left_Turret_Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.SERAPHIM * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 10,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 11500,
            ["regen"] = 10,
            ["value"] = 11500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 60000,
        ["cost"] = {
            ["alloys"] = 18000,
            ["energy"] = 5000000,
        },
        ["initial"] = {
            ["alloys"] = 650,
            ["energy"] = 4000,
        },
        ["production"] = {
            ["alloys"] = 1,
            ["energy"] = 20,
        },
        ["storage"] = {
            ["alloys"] = 650,
            ["energy"] = 4000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 0.7,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimCommander",
        },
        ["displayName"] = "Armored Command Unit",
        ["icon"] = {
            ["shape"] = "bot2",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_bot2_direct.png",
        ["iconUIBuildSortPriority"] = 1000,
        ["iconUIType"] = "land",
        ["name"] = "Armored Command Unit",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Pause"] = true,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 989.4,
            ["WaterSurface"] = 989.4,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "usl0000",
        ["unitTypeName"] = "UnknownCommander",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 1.7,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "SeabedSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "SeabedSmall",
        },
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 0.5,
                ["z"] = 1.2,
            },
        },
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 1.7,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsSeabed",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 1.54545454545455,
        },
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 10,
        },
        [6] = {
            ["innerRadius"] = 2,
            ["outerRadius"] = 22,
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
        [1] = "ALLOYS_PRODUCTION",
        [2] = "ALLOYS_STORAGE",
        [3] = "ANTI_SURFACE",
        [4] = "CAPTURE",
        [5] = "COMMAND",
        [6] = "CONSTRUCTION",
        [7] = "DIRECT_FIRE",
        [8] = "ECONOMIC",
        [9] = "ENERGY_PRODUCTION",
        [10] = "ENERGY_STORAGE",
        [11] = "HARVEST",
        [12] = "MOBILE",
        [13] = "SCFA_ABILITYBUTTON",
        [14] = "SCFA_ALLUNITS",
        [15] = "SCFA_CAPTURE",
        [16] = "SCFA_COMMAND",
        [17] = "SCFA_CONSTRUCTION",
        [18] = "SCFA_DIRECTFIRE",
        [19] = "SCFA_ECONOMIC",
        [20] = "SCFA_ENERGYPRODUCTION",
        [21] = "SCFA_ENGINEER",
        [22] = "SCFA_LAND",
        [23] = "SCFA_MASSFABRICATION",
        [24] = "SCFA_MASSPRODUCTION",
        [25] = "SCFA_MOBILE",
        [26] = "SCFA_OVERLAYDIRECTFIRE",
        [27] = "SCFA_OVERLAYINDIRECTFIRE",
        [28] = "SCFA_OVERLAYOMNI",
        [29] = "SCFA_PATROLHELPER",
        [30] = "SCFA_PRODUCTFA",
        [31] = "SCFA_RECLAIM",
        [32] = "SCFA_REPAIR",
        [33] = "SCFA_SELECTABLE",
        [34] = "SCFA_SERAPHIM",
        [35] = "SCFA_SHOWQUEUE",
        [36] = "SCFA_SILO",
        [37] = "SCFA_VISIBLETORECON",
        [38] = "SERAPHIM",
        [39] = "TECH1",
        [40] = "LAND",
        [41] = "SEABED",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl0000/LOD0/usl0000.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl0000/LOD0/usl0000.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 1.54545454545455,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/usl0000/LOD0/usl0000.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/usl0000/LOD0/usl0000.sananimation",
            },
            ["source_animunfold"] = {
                ["clipName"] = "AnimUnfold",
                ["sanAnimationPath"] = "Units/usl0000/LOD0/usl0000.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl0000/LOD0/usl0000.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd0301_death_rdu.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 1.6500000000000001,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 1.496,
                    ["z"] = 0.126,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 1.7160000000000002,
                    ["z"] = 0.11199999999999999,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 2.024,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 1.9800000000000002,
                    ["z"] = 0.126,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 72,
            ["lod1distance"] = 189,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 0.6,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Arm_B02",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 100,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom1120",
                },
            },
            ["damage"] = 100,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Commanders/ChosenStyle/Seraphim/muzzle.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0.4,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Turret_Muzzle"] = {
                    ["aimController"] = "Right_Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 5,
            ["projectileTemplate"] = "psf0169",
            ["rangeMax"] = 22,
            ["rangeMin"] = 2,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1.4,
            ["scoCommanderEnhancementBaseWeapon"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f402241e24e5f2e0ba2a1c9f1930308c0c988c5b9500f7404511a199d0f1d2a5",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ChronotronCannon",
                ["sourceProjectile"] = "/projectiles/SDFChronatronCannon01/SDFChronatronCannon01_proj.bp",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 5000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 15,
            ["damageType"] = "Normal",
        },
    },
}
