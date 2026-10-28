-- uel0000: Armored Command Unit
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["version"] = "1.0.0",
            ["projectileTemplate"] = "pocuef",
        },
        ["multiConstructionBeam"] = {
            ["materialPath"] = "VFX/SCOM/ConstructionBeams/uef.sanmaterial",
            ["prefabName"] = "SCOM.UefCommanderSliceBeams",
            ["shrink"] = 0.05,
            ["uefSliceBeams"] = true,
        },
        ["buildBeamBones"] = {
            [1] = "Left_Arm_Muzzle",
        },
        ["buildBeamEffectName"] = "beam1",
        ["displayWreckOnDeath"] = false,
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0.0011789119802415372,
                [2] = 1.8499463775249654,
                [3] = -0.10207693100612202,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = true,
            ["foldDuration"] = 2.5333333015441895,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0001",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 419589,
                ["entry"] = "units/UEL0001/UEL0001_LOD0.scm",
                ["sha256"] = "2cc293d581fc3dea1ea2462932df1bb4232b07a624cbcfb9d1ea048866127767",
            },
            ["unfoldDuration"] = 0.5333333611488342,
        },
        ["scoCommanderEnhancementBaseWeaponIndex"] = 1,
        ["scoCommanderEnhancementShields"] = {
            ["uefField"] = 2,
            ["uefPersonal"] = 1,
        },
        ["scoCommanderEnhancements"] = {
            ["baseBuildCategory"] = "Tags.EDA * Tags.BUILDABLE_BY_T1_ENGINEER",
            ["capabilities"] = {
                ["chronoStun"] = false,
                ["cloak"] = "visual-aura",
                ["manualMissiles"] = true,
                ["omni"] = false,
                ["sonar"] = false,
                ["spawnPods"] = true,
                ["stealth"] = "visual-aura",
                ["teleport"] = true,
            },
            ["faction"] = "UEF",
            ["patchVersion"] = "1.0.4",
            ["radarPredeclared"] = false,
            ["sourceId"] = "UEL0001",
            ["version"] = "1.0.0",
        },
        ["scoGameplayCommanderBeam"] = "1.3.0",
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Left_Footfall01",
                    ["contactOffset"] = {
                        ["x"] = -0.008655425783813786,
                        ["y"] = 0.0949271203045404,
                        ["z"] = -0.0021949622095856006,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 0.2588189798554028,
                        ["y"] = 0.9659258908793898,
                        ["z"] = 1.584546164279388e-07,
                    },
                    ["length"] = 0.5349551886320114,
                    ["liftHeight"] = 0.1505960481898682,
                    ["minimumHeight"] = -0.022581598157746414,
                    ["plantHeight"] = 0.022418401842253584,
                    ["right"] = {
                        ["x"] = 0.9659258453770707,
                        ["y"] = -0.2588189798553122,
                        ["z"] = -3.881909558245411e-07,
                    },
                    ["width"] = 0.33394576609134674,
                },
                [2] = {
                    ["boneName"] = "Left_Footfall",
                    ["contactOffset"] = {
                        ["x"] = 0.00756091453397717,
                        ["y"] = 0.0946333331088352,
                        ["z"] = -0.0021950279956591823,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = -0.25881920912519796,
                        ["y"] = 0.9659257756746695,
                        ["z"] = 1.2893164860194872e-06,
                    },
                    ["length"] = 0.5349551290273666,
                    ["liftHeight"] = 0.1199194829307742,
                    ["minimumHeight"] = -0.023206153678200253,
                    ["plantHeight"] = 0.021793846321799745,
                    ["right"] = {
                        ["x"] = 0.9659257821111064,
                        ["y"] = 0.258819209122624,
                        ["z"] = 1.879943363647385e-06,
                    },
                    ["width"] = 0.33394595980644226,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/uel0000/LOD0/uel0000_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "uel0000",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scomRestoredAnimations"] = {
            ["assetSha256"] = "f5c5c8a31329806954549542b1f83b823660121237ed2265b9d529f909a1289b",
            ["runtimeRate"] = 1,
            ["sourceDeathRateRandomization"] = false,
            ["sourceId"] = "UEL0001",
            ["transportEventBinding"] = "source cargo load/unload lifecycle",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = -0.09,
                ["y"] = 0.97,
                ["z"] = 0.43,
            },
            ["size"] = {
                ["x"] = 2.4,
                ["y"] = 2.3,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1305",
        },
        ["onDamagedAlert"] = {
            ["looping"] = false,
            ["name"] = "dx_uni_evaf_Pxx_Sc",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod0000",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = -0.09,
            ["y"] = 0.97,
            ["z"] = 0.43,
        },
        ["collisionSize"] = {
            ["x"] = 2.2,
            ["y"] = 2.2,
            ["z"] = 2.1,
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
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 10,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 12000,
            ["regen"] = 10,
            ["value"] = 12000,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["entityName"] = "SCOUefPersonalShieldEntity",
                ["max"] = 1,
                ["name"] = "Commander Enhancement Shield",
                ["offset"] = {
                    ["x"] = -0.09,
                    ["y"] = -0.1517918395996094,
                    ["z"] = 0.43,
                },
                ["radii"] = {
                    ["x"] = 1.5,
                    ["y"] = 1.5,
                    ["z"] = 1.5,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 5,
                ["regen"] = 0,
                ["regenDelay"] = 1,
                ["scoCommanderEnhancementShieldId"] = "uefPersonal",
                ["type"] = "Bubble",
                ["value"] = 1,
            },
            [2] = {
                ["boneName"] = "Root",
                ["entityName"] = "SCOUefFieldShieldEntity",
                ["max"] = 1,
                ["name"] = "Commander Enhancement Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -4.121791839599609,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 8,
                    ["y"] = 8,
                    ["z"] = 8,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 5,
                ["regen"] = 0,
                ["regenDelay"] = 1,
                ["scoCommanderEnhancementShieldId"] = "uefField",
                ["type"] = "Bubble",
                ["value"] = 1,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 80000,
        ["cost"] = {
            ["alloys"] = 10000,
            ["energy"] = 100000,
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
            ["energy"] = 5000,
        },
    },
    ["footprint"] = {
        ["x"] = 2.6,
        ["y"] = 2.5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDACommander",
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
            ["Pause"] = false,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 271,
            ["WaterSurface"] = 271,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Shield"] = true,
        },
        ["tpId"] = "uel0000",
        ["unitTypeName"] = "EDACommander",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 1.7,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 1.7,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 1,
        },
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 10,
        },
        [6] = {
            ["innerRadius"] = 1,
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
        [9] = "EDA",
        [10] = "ENERGY_PRODUCTION",
        [11] = "ENERGY_STORAGE",
        [12] = "HARVEST",
        [13] = "LAND",
        [14] = "MOBILE",
        [15] = "TECH1",
        [16] = "SCFA_ALLUNITS",
        [17] = "SCFA_CAPTURE",
        [18] = "SCFA_COMMAND",
        [19] = "SCFA_CONSTRUCTION",
        [20] = "SCFA_DIRECTFIRE",
        [21] = "SCFA_ECONOMIC",
        [22] = "SCFA_ENERGYPRODUCTION",
        [23] = "SCFA_ENGINEER",
        [24] = "SCFA_LAND",
        [25] = "SCFA_MASSFABRICATION",
        [26] = "SCFA_MASSPRODUCTION",
        [27] = "SCFA_MOBILE",
        [28] = "SCFA_OVERLAYDEFENSE",
        [29] = "SCFA_OVERLAYDIRECTFIRE",
        [30] = "SCFA_OVERLAYINDIRECTFIRE",
        [31] = "SCFA_OVERLAYOMNI",
        [32] = "SCFA_PATROLHELPER",
        [33] = "SCFA_PODSTAGINGPLATFORM",
        [34] = "SCFA_PRODUCTSC1",
        [35] = "SCFA_RECLAIM",
        [36] = "SCFA_REPAIR",
        [37] = "SCFA_SELECTABLE",
        [38] = "SCFA_SHOWQUEUE",
        [39] = "SCFA_SILO",
        [40] = "SCFA_UEF",
        [41] = "SCFA_VERIFYMISSILEUI",
        [42] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel0000/LOD0/uel0000.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel0000/LOD0/uel0000.sananimation",
            },
            ["fold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel0000/LOD0/uel0000.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimWalk01",
                ["sanAnimationPath"] = "Units/uel0000/LOD0/uel0000.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["unfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel0000/LOD0/uel0000.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uel0000/LOD0/uel0000.sananimation",
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
                    ["audioName"] = "eda_unit_death_rdu",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved0301_death_rdu.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30600000000000005,
                    ["y"] = 1.52,
                    ["z"] = 0.009999999999999953,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.5740000000000001,
                    ["y"] = 1.366,
                    ["z"] = 0.808,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.3500000000000001,
                    ["y"] = 1.586,
                    ["z"] = 0.766,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30600000000000005,
                    ["y"] = 1.8940000000000001,
                    ["z"] = 0.009999999999999953,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.5740000000000001,
                    ["y"] = 1.85,
                    ["z"] = 0.808,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 88,
            ["lod1distance"] = 230,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = -0.09,
                ["y"] = 0.97,
                ["z"] = 0.43,
            },
            ["size"] = {
                ["x"] = 2.4,
                ["y"] = 2.3,
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
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Arm_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -60,
                    ["pitchSpeed"] = 90,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom1130",
                },
            },
            ["damage"] = 100,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/CommanderBrightness/f091c5024cc82e75bd1b.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
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
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Arm_Muzzle"] = {
                    ["aimController"] = "Right_Arm_Muzzle",
                },
            },
            ["projectileLifetime"] = 10,
            ["projectileTemplate"] = "psf0168",
            ["rangeMax"] = 22,
            ["rangeMin"] = 1,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoCommanderEnhancementBaseWeapon"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "4a1d33796c7896993dbee6f3a309a4ff56fa0c97900b1e3f702aafcf363437fe",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "RightZephyr",
                ["sourceProjectile"] = "/projectiles/LaserBotTerran01/LaserBotTerran01_proj.bp",
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
