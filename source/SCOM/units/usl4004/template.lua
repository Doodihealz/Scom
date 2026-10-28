-- usl4004: Ythotha
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Top_Claw",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "Bottom_Claw",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixYthothaClaw"] = {
            ["chargeDelaySeconds"] = 2.5,
            ["chargeTicks"] = 25,
            ["closeSpeed"] = 50,
            ["closeTicks"] = 5,
            ["dedicatedProjectileTemplateRequired"] = true,
            ["fireDegrees"] = 25,
            ["lowerBone"] = "Bottom_Claw",
            ["openDegrees"] = 45,
            ["openSpeed"] = 10,
            ["projectileTemplate"] = "psu404s",
            ["requestedPresentationSide"] = "visible-left",
            ["requestedProjectileVisualScale"] = 3,
            ["rotationAxis"] = "x",
            ["runtimeManipulatorConsumerRequired"] = false,
            ["sourceWeaponName"] = "RightArm",
            ["upperBone"] = "Top_Claw",
            ["version"] = "1.0.0",
            ["weaponIndex"] = 3,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Right_Foot",
                    ["contactOffset"] = {
                        ["x"] = 0.13002458437101605,
                        ["y"] = -0.0005886179263398447,
                        ["z"] = -0.4962264214534393,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = -0.0063219668859043465,
                        ["y"] = 0.020929578892455006,
                        ["z"] = -0.9997609641619729,
                    },
                    ["length"] = 1.7321181297302246,
                    ["liftHeight"] = 0.4379116089414514,
                    ["minimumHeight"] = -0.1276108213017768,
                    ["plantHeight"] = -0.08261082130177681,
                    ["right"] = {
                        ["x"] = -0.9996189087321394,
                        ["y"] = -0.02699828246973745,
                        ["z"] = 0.005755870816021353,
                    },
                    ["width"] = 0.8772630095481873,
                },
                [2] = {
                    ["boneName"] = "Left_Foot",
                    ["contactOffset"] = {
                        ["x"] = -0.11690793143353673,
                        ["y"] = -0.01821595238308167,
                        ["z"] = -0.4506008414405126,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 0.021091587133474973,
                        ["y"] = -0.01631463174105835,
                        ["z"] = -0.9996444256551156,
                    },
                    ["length"] = 1.7321177273988724,
                    ["liftHeight"] = 0.5218878259658266,
                    ["minimumHeight"] = -0.046146929708522716,
                    ["plantHeight"] = -0.001146929708522721,
                    ["right"] = {
                        ["x"] = -0.9996724327022812,
                        ["y"] = 0.014154471677390326,
                        ["z"] = -0.02132318518978363,
                    },
                    ["width"] = 0.877263069152832,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/usl4004/LOD0/usl4004_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "usl4004",
        },
        ["scoSpecial"] = {
            ["animations"] = {
                ["activate"] = {
                    ["clipName"] = "AnimActivate",
                    ["duration"] = 1.3333333730697632,
                    ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
                },
                ["adeath01"] = {
                    ["clipName"] = "AnimAdeath01",
                    ["duration"] = 4,
                    ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
                },
                ["adeath02"] = {
                    ["clipName"] = "AnimAdeath02",
                    ["duration"] = 4,
                    ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
                },
                ["awalk"] = {
                    ["clipName"] = "AnimWalk",
                    ["duration"] = 4,
                    ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
                },
            },
            ["bigBones"] = {
                [1] = "Torso",
                [2] = "Head",
                [3] = "pelvis",
            },
            ["child"] = "usl5002",
            ["deathDamage"] = {
                ["Damage"] = 10000,
                ["DamageFriendly"] = true,
                ["DamageRadius"] = 8,
            },
            ["effects"] = {
                ["deathPulse"] = {
                    ["bone"] = "Root",
                    ["loop"] = false,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/psf0125/impact_land.sanvfx",
                },
                ["explosion"] = {
                    ["bone"] = "Root",
                    ["loop"] = false,
                    ["offset"] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = 0,
                    },
                    ["path"] = "VFX/SCOM/Source/usl4004/explosion.sanvfx",
                },
            },
            ["explosionBones"] = {
                [1] = "Right_Arm_B07",
                [2] = "Right_Arm_B03",
                [3] = "Left_Arm_B10",
                [4] = "Left_Arm_B07",
                [5] = "Chest_B01",
                [6] = "Chest_B03",
                [7] = "Right_Leg_B01",
                [8] = "Right_Leg_B02",
                [9] = "Right_Leg_B03",
                [10] = "Left_Leg_B17",
                [11] = "Left_Leg_B14",
                [12] = "Left_Leg_B15",
            },
            ["finalDelay"] = 3.5,
            ["initialDelay"] = 2,
            ["kind"] = "ythotha",
            ["sourceId"] = "XSL0401",
        },
        ["scoYthothaAimArc"] = {
            ["controllerCount"] = 5,
            ["rearAimExcluded"] = true,
            ["sourceBlueprintSha256"] = "14f9f8c5566774931c0ebdd308088a3731857b3c2fd373f9cc4a4f01c00c83d4",
            ["sourceId"] = "XSL0401",
            ["version"] = "1.0.0",
        },
        ["scoYthothaContactAudio"] = true,
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 4.55,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.2,
                ["y"] = 1.6,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 4,
                ["key"] = "source_animadeath01",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
            },
            [2] = {
                ["durationSeconds"] = 4,
                ["key"] = "source_animadeath02",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1143",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 4.55,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.5,
            ["y"] = 8.5,
            ["z"] = 1.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 67000,
            ["regen"] = 20,
            ["value"] = 67000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 18750,
        ["cost"] = {
            ["alloys"] = 25000,
            ["energy"] = 312500,
        },
    },
    ["footprint"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Ythotha",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "none",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech3_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "amphibious",
        ["name"] = "Ythotha",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 5746.5,
            ["Land"] = 43071.8,
            ["WaterSurface"] = 23622.8,
        },
        ["tpId"] = "usl4004",
        ["unitTypeName"] = "UnknownT4Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 50,
    },
    ["movement"] = {
        ["acceleration"] = 2.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "SeabedLarge",
        },
        ["collisionMaskSpawn"] = {
            [1] = "SeabedLarge",
        },
        ["deceleration"] = 2.5,
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 8,
                ["y"] = 0.5,
                ["z"] = 8,
            },
        },
        ["mass"] = 0,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 40,
        ["sortOrder"] = 1,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsSeabed",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 2.27272727272727,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 4,
            ["outerRadius"] = 45,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 45,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 50,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 50,
        },
    },
    ["skirtSize"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "ANTI_SURFACE",
        [3] = "BOT",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "DIRECT_FIRE",
        [6] = "INDIRECT_FIRE",
        [7] = "MOBILE",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DIRECTFIRE",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_EXPERIMENTAL",
        [14] = "SCFA_LAND",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_NEEDMOBILEBUILD",
        [17] = "SCFA_OVERLAYANTIAIR",
        [18] = "SCFA_OVERLAYDIRECTFIRE",
        [19] = "SCFA_PRODUCTFA",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SERAPHIM",
        [23] = "SCFA_SHOWATTACKRETICLE",
        [24] = "SCFA_VISIBLETORECON",
        [25] = "SERAPHIM",
        [26] = "TECH4",
        [27] = "LAND",
        [28] = "SEABED",
    },
    ["visuals"] = {
        ["animations"] = {
            ["run"] = {
                ["authoredSpeed"] = 2.27272727272727,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["scoSpecial_activate"] = {
                ["clipName"] = "AnimActivate",
                ["duration"] = 1.3333333730697632,
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
            },
            ["scoSpecial_adeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["duration"] = 4,
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
            },
            ["scoSpecial_adeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["duration"] = 4,
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
            },
            ["scoSpecial_awalk"] = {
                ["clipName"] = "AnimWalk",
                ["duration"] = 4,
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
            },
            ["source_animactivate"] = {
                ["clipName"] = "AnimActivate",
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl4004/LOD0/usl4004.sananimation",
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd0301_death_rdu.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 6.675,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 6.08,
                    ["z"] = 0.27,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.5,
                    ["y"] = 6.93,
                    ["z"] = 0.24,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44999999999999996,
                    ["y"] = 8.12,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.55,
                    ["y"] = 7.95,
                    ["z"] = 0.27,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 346,
            ["lod1distance"] = 900,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 4.55,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.2,
                ["y"] = 1.6,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Head",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Head",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 8,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Head",
                    ["yawMax"] = 35,
                    ["yawMin"] = -35,
                    ["yawSpeed"] = 40,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["name"] = "acom2140",
                },
            },
            ["damage"] = 8000,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl4004/muzzle_eyeweapon.sanvfx",
            },
            ["firingRandomness"] = 3,
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
                        [1] = "Head",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Head"] = {
                    ["aimController"] = "Head",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0125",
            ["rangeMax"] = 45,
            ["rangeMin"] = 4,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "5fd91d2d4cf835ff44072a55399c843ec1865f123543863a82c6c3c3582893fe",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "EyeWeapon",
                ["sourceProjectile"] = "/projectiles/SDFExperimentalPhasonProj01/SDFExperimentalPhasonProj01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "EyeWeapon",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "LeftHand_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Left_Arm_B07",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Arm_B10",
                    ["yawMax"] = 35,
                    ["yawMin"] = -35,
                    ["yawSpeed"] = 50,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["name"] = "acom1114",
                },
            },
            ["damage"] = 550,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl4004/muzzle_leftarm.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "LeftHand_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["LeftHand_Muzzle"] = {
                    ["aimController"] = "LeftHand_Muzzle",
                },
            },
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "psf0124",
            ["rangeMax"] = 45,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.3333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f60822ad77e7739cf19a4b65a0fbbee7230b6a4fcc0de9db6fa15019a8e22597",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "LeftArm",
                ["sourceProjectile"] = "/projectiles/SDFAireauWeapon01/SDFAireauWeapon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "LeftArm",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "RightHand_Muzzle",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Arm_B03",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 40,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Right_Arm_B07",
                    ["yawMax"] = 35,
                    ["yawMin"] = -35,
                    ["yawSpeed"] = 50,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["name"] = "acom1114",
                },
            },
            ["damage"] = 1200,
            ["damageRadius"] = 6,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 2.5,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "RightHand_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["RightHand_Muzzle"] = {
                    ["aimController"] = "RightHand_Muzzle",
                },
            },
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "psu404s",
            ["rangeMax"] = 45,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 3.3333333333333335,
            ["scoFieldFixYthothaCharge"] = {
                ["chargeTicks"] = 25,
                ["closeSpeed"] = 50,
                ["closeTicks"] = 5,
                ["lowerBone"] = "Bottom_Claw",
                ["openSpeed"] = 10,
                ["upperBone"] = "Top_Claw",
                ["version"] = "1.0.0",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Left_AA_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchAxis"] = {
                        ["x"] = -1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["pitchBone"] = "Left_AA_Turret03",
                    ["pitchMax"] = 25,
                    ["pitchMin"] = -80,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 20,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_AA_Turret03",
                    ["yawMax"] = 90,
                    ["yawMin"] = -90,
                    ["yawSpeed"] = 180,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looped"] = false,
                    ["name"] = "acom2224",
                },
            },
            ["damage"] = 25,
            ["damageRadius"] = 1.5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl4004/muzzle_leftaa.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Left_AA_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Left_AA_Muzzle"] = {
                    ["aimController"] = "Left_AA_Muzzle",
                },
            },
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "psf0105",
            ["rangeMax"] = 45,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "2143068adec9f3f97c804255fb5b2534e53d693eb44a9a2b99d0110b88c4ecb1",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "LeftAA",
                ["sourceProjectile"] = "/projectiles/SAAOlarisAAArtillery03/SAAOlarisAAArtillery03_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "LeftAA",
            },
            ["targetWaterLimits"] = "Above",
        },
        [5] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_AA_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchAxis"] = {
                        ["x"] = -1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["pitchBone"] = "Right_AA_Turret02",
                    ["pitchMax"] = 25,
                    ["pitchMin"] = -80,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 20,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_AA_Turret02",
                    ["yawMax"] = 90,
                    ["yawMin"] = -90,
                    ["yawSpeed"] = 180,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["name"] = "acom2224",
                },
            },
            ["damage"] = 25,
            ["damageRadius"] = 1.5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl4004/muzzle_rightaa.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_AA_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_AA_Muzzle"] = {
                    ["aimController"] = "Right_AA_Muzzle",
                },
            },
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "psf0105",
            ["rangeMax"] = 45,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "2143068adec9f3f97c804255fb5b2534e53d693eb44a9a2b99d0110b88c4ecb1",
                ["sourceIndex"] = 5,
                ["sourceLabel"] = "RightAA",
                ["sourceProjectile"] = "/projectiles/SAAOlarisAAArtillery03/SAAOlarisAAArtillery03_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 5,
                ["sourceLabel"] = "RightAA",
            },
            ["targetWaterLimits"] = "Above",
        },
        [6] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 15000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 12,
            ["damageType"] = "Normal",
        },
    },
}

-- Retail Seraphim combat correction.
do
    local tp = UnitTemplate
        local weapon = assert(tp.weapons[1])
        assert(tp.general.tpId == 'usl4004' and weapon.projectileTemplate == 'psf0125'
            and weapon.scoFaProjectileIdentity.sourceLabel == 'EyeWeapon', 'Ythotha eye scope drift')
        weapon.scoSeraphimHeadChargeTicks = 25
        local effects = assert(tp.additions.scoSpecial.effects)
        effects.headCharge = {path = 'VFX/SCOM/Combat/ythotha_head_charge.sanvfx',
            bone = 'Head', offset = {0, 0, 0}, loop = true}
end
