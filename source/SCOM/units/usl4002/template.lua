-- usl4002: Support Armored Command Unit
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Left_Arm_Muzzle",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -2.1493660185001323e-10,
                [2] = 2.103516917941901,
                [3] = 0.03401721936668962,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["foldDuration"] = 2.5,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0301",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 218759,
                ["entry"] = "units/XSL0301/XSL0301_lod0.scm",
                ["sha256"] = "2d8e79e14c822538879baa7aad2abede27015c41f9557b46ba860a4c33f065de",
            },
            ["unfoldDuration"] = 0.3333333432674408,
        },
        ["scoCommanderEnhancementShields"] = {
            ["usl4002_Shield"] = 1,
        },
        ["scoCommanderEnhancementWeapons"] = {
            ["LightChronatronCannon"] = 1,
            ["Missile"] = 3,
            ["OverCharge"] = 2,
        },
        ["scoCommanderEnhancements"] = {
            ["faction"] = "Seraphim",
            ["sourceId"] = "XSL0301",
            ["version"] = "1.0.0",
        },
        ["scoGameplayCommanderBeam"] = "1.3.0",
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Left_Foot",
                    ["contactOffset"] = {
                        ["x"] = -0.0025329239666462,
                        ["y"] = -0.1042154722685482,
                        ["z"] = 0.08323458203781688,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163512e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.38603823632001877,
                    ["liftHeight"] = 0.08600258983687951,
                    ["minimumHeight"] = -0.019765824328060455,
                    ["plantHeight"] = 0.025234175671939543,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.25213537365198135,
                },
                [2] = {
                    ["boneName"] = "Right_Foot",
                    ["contactOffset"] = {
                        ["x"] = 0.004145012795925163,
                        ["y"] = -0.10421551976597997,
                        ["z"] = 0.08323465058316402,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163512e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.3860381469130516,
                    ["liftHeight"] = 0.08535062100362861,
                    ["minimumHeight"] = -0.020635918161531847,
                    ["plantHeight"] = 0.024364081838468152,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.25213538110256195,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/usl4002/LOD0/usl4002_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "usl4002",
        },
        ["scoSupportCommanderEnhancements"] = true,
        ["scoSupportCommanderTech"] = "1.0.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.85,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.5,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1346",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1141",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.85,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.75,
            ["y"] = 1.7,
            ["z"] = 0.4,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Left_Arm_Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 60,
        ["canBuild"] = "(Tags.SERAPHIM * Tags.BUILDABLE_BY_T3_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 31000,
            ["regen"] = 15,
            ["value"] = 31000,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["entityName"] = "SCOShield_Shield",
                ["max"] = 1,
                ["name"] = "Personal Shield Generator",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 1.275,
                    ["y"] = 1.275,
                    ["z"] = 1.275,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 5,
                ["regen"] = 0,
                ["regenDelay"] = 1,
                ["scoCommanderEnhancementShieldId"] = "usl4002_Shield",
                ["type"] = "Bubble",
                ["value"] = 1,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 36000,
        ["cost"] = {
            ["alloys"] = 9300,
            ["energy"] = 117000,
        },
        ["production"] = {
            ["alloys"] = 5,
            ["energy"] = 500,
        },
        ["storage"] = {
            ["alloys"] = 275,
            ["energy"] = 5000,
        },
    },
    ["footprint"] = {
        ["x"] = 0.75,
        ["y"] = 0.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Support Armored Command Unit",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "none",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech3_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "amphibious",
        ["name"] = "Support Armored Command Unit",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 19384.4,
            ["WaterSurface"] = 8168.7,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "usl4002",
        ["unitTypeName"] = "UnknownT4Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 2.2,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "SeabedLarge",
        },
        ["collisionMaskSpawn"] = {
            [1] = "SeabedLarge",
        },
        ["deceleration"] = 2.2,
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 8,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 4,
                ["y"] = 0.5,
                ["z"] = 3.5,
            },
        },
        ["mass"] = 0,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 150,
        ["sortOrder"] = 1,
        ["speed"] = 2.2,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsSeabed",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 2.2,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 1,
            ["outerRadius"] = 25,
        },
        [7] = {
            ["innerRadius"] = 5,
            ["outerRadius"] = 256,
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
        [3] = "BOT",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "ENERGY_PRODUCTION",
        [6] = "ENERGY_STORAGE",
        [7] = "MOBILE",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYQUANTUMGATE",
        [10] = "SCFA_CAPTURE",
        [11] = "SCFA_CONSTRUCTION",
        [12] = "SCFA_ENGINEER",
        [13] = "SCFA_LAND",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYDIRECTFIRE",
        [16] = "SCFA_OVERLAYOMNI",
        [17] = "SCFA_PATROLHELPER",
        [18] = "SCFA_PRODUCTFA",
        [19] = "SCFA_REBUILDER",
        [20] = "SCFA_RECLAIM",
        [21] = "SCFA_REPAIR",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SERAPHIM",
        [24] = "SCFA_SHOWQUEUE",
        [25] = "SCFA_SILO",
        [26] = "SCFA_SUBCOMMANDER",
        [27] = "SCFA_TECH3",
        [28] = "SCFA_VISIBLETORECON",
        [29] = "SERAPHIM",
        [30] = "TECH3",
        [31] = "LAND",
        [32] = "SEABED",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4002/LOD0/usl4002.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl4002/LOD0/usl4002.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 2.2,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/usl4002/LOD0/usl4002.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/usl4002/LOD0/usl4002.sananimation",
            },
            ["source_animunfold"] = {
                ["clipName"] = "AnimUnfold",
                ["sanAnimationPath"] = "Units/usl4002/LOD0/usl4002.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl4002/LOD0/usl4002.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 1.275,
                    ["z"] = -0.08000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 1.156,
                    ["z"] = 0.072,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.15000000000000002,
                    ["y"] = 1.326,
                    ["z"] = 0.064,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 1.564,
                    ["z"] = -0.08000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 1.53,
                    ["z"] = 0.072,
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
                ["y"] = 0.85,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.5,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Arm_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Arm",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 45,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom2234",
                },
            },
            ["damage"] = 100,
            ["damageOverTimePulseCount"] = 10,
            ["damageOverTimePulseDamage"] = 40,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/CommanderBrightness/67f193c0a63061c7fda6.sanvfx",
            },
            ["firingRandomness"] = 5,
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
                        [1] = "Right_Arm_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.5,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Right_Arm_Muzzle"] = {
                    ["aimController"] = "Right_Arm_Muzzle",
                },
            },
            ["projectileLifetime"] = 60,
            ["projectileTemplate"] = "pcc170",
            ["rangeMax"] = 25,
            ["rangeMin"] = 1,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f25503b46c9fb155abaf27e668adf12e1d940e49683ee5f395b018b463272312",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LightChronatronCannon",
                ["sourceProjectile"] = "/projectiles/SDFLightChronatronCannon01/SDFLightChronatronCannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LightChronatronCannon",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Arm_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Arm",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 22,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom2234",
                },
            },
            ["damage"] = 12000,
            ["damageRadius"] = 2.5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/CommanderBrightness/67f193c0a63061c7fda6.sanvfx",
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
                        [1] = "Right_Arm_Muzzle",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Arm_Muzzle"] = {
                    ["aimController"] = "Right_Arm_Muzzle",
                },
            },
            ["projectileTemplate"] = "psf0171",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 3.33333333333333,
            ["scoCommanderEnhancementRequired"] = "Overcharge",
            ["scoCommanderEnhancementUnsupported"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "b5ec0a879c09ad86f4fc5c74f8ffa9188396601e1c580a880579fa9ca11b8098",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "OverCharge",
                ["sourceProjectile"] = "/projectiles/SDFLightChronatronCannon02/SDFLightChronatronCannon02_proj.bp",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "back_missile",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "back_missile",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "back_missile",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom5114",
                },
            },
            ["damage"] = 6000,
            ["damageRadius"] = 3,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/CommanderBrightness/4cb2e20e50b93c2320be.sanvfx",
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
                        [1] = "back_missile",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["back_missile"] = {
                    ["aimController"] = "back_missile",
                },
            },
            ["projectileTemplate"] = "psf0141",
            ["rangeMax"] = 256,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoCommanderEnhancementRequired"] = "Missile",
            ["scoCommanderEnhancementUnsupported"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "fc6d640a7385c24fc60bc4b9614572461fa0eee4afb2de0b0120f4b92e6456c3",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "Missile",
                ["sourceProjectile"] = "/projectiles/SIFLaanseTacticalMissileSCU/SIFLaanseTacticalMissileSCU_proj.bp",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 15000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 12,
            ["damageType"] = "Normal",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["weapons"][2]["audio"] = UnitTemplate["weapons"][1]["audio"]
UnitTemplate["weapons"][2]["effects"] = UnitTemplate["weapons"][1]["effects"]
