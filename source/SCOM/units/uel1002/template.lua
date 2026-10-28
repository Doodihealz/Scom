-- uel1002: Mech Marine
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["dormantFoldClip"] = "AnimFold",
            ["dormantReason"] = "Sanctuary exposes no transport fold callback",
            ["dualManipulatorAimControllers"] = 2,
            ["sourceBlueprintSha256"] = "1da83e388eb0dfb4dd12ccee5d482a10b9bdc0a3b966f8689280bf6177aa5768",
            ["sourceId"] = "UEL0106",
            ["sourceScriptSha256"] = "51d822b8c922dd5e92639ec97dc37f87df2a1ac1ba7ac4807d9f555706eb1952",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -1.5459491464753228e-09,
                [2] = 0.4325648917965361,
                [3] = 0.012838542919998303,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["foldDuration"] = 1.3333333730697632,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0106",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 43593,
                ["entry"] = "units/UEL0106/UEL0106_LOD0.scm",
                ["sha256"] = "c808c53f1cec2e937f6bf69ec45046cd07bc6454eab355922753b80e099af147",
            },
            ["unfoldDuration"] = 1.3333333730697632,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Leg_Right_B03",
                    ["contactOffset"] = {
                        ["x"] = 0.0002537329878651712,
                        ["y"] = -0.04070586890113366,
                        ["z"] = 0.04554612769322888,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.01796189203568164,
                        ["y"] = 0.499017429691729,
                        ["z"] = 0.8664057798158775,
                    },
                    ["length"] = 0.16751078516244888,
                    ["liftHeight"] = 0.06671407146464707,
                    ["minimumHeight"] = -0.023055873286625964,
                    ["plantHeight"] = 0.021944126713374035,
                    ["right"] = {
                        ["x"] = 0.9992529571168095,
                        ["y"] = -0.03861606969285511,
                        ["z"] = 0.001525403155941945,
                    },
                    ["width"] = 0.11045387014746666,
                },
                [2] = {
                    ["boneName"] = "Leg_Left_B03",
                    ["contactOffset"] = {
                        ["x"] = -0.00026518172473380397,
                        ["y"] = -0.04064981411461584,
                        ["z"] = 0.04550079320210002,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.018276229069027154,
                        ["y"] = 0.4980742635437731,
                        ["z"] = 0.86694175550976,
                    },
                    ["length"] = 0.16751216351985931,
                    ["liftHeight"] = 0.060555789567025994,
                    ["minimumHeight"] = -0.02297088060538796,
                    ["plantHeight"] = 0.022029119394612037,
                    ["right"] = {
                        ["x"] = 0.9993020248308823,
                        ["y"] = 0.037353821718721106,
                        ["z"] = -0.0003939186525220989,
                    },
                    ["width"] = 0.1104593351483345,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/uel1002/LOD0/uel1002_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "uel1002",
        },
        ["scoIdleResetLocomotion"] = true,
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1315",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.3,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.6,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 75,
            ["regen"] = 0,
            ["value"] = 75,
        },
    },
    ["economy"] = {
        ["buildTime"] = 140,
        ["cost"] = {
            ["alloys"] = 35,
            ["energy"] = 140,
        },
    },
    ["footprint"] = {
        ["x"] = 0.6,
        ["y"] = 0.6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAImportedFaLandUnit",
        },
        ["displayName"] = "Mech Marine",
        ["icon"] = {
            ["shape"] = "bot1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_bot1_direct.png",
        ["iconUIBuildSortPriority"] = 90,
        ["iconUIType"] = "land",
        ["name"] = "Mech Marine",
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
            ["Land"] = 36.8,
            ["WaterSurface"] = 49.8,
        },
        ["tpId"] = "uel1002",
        ["unitTypeName"] = "EDAT1Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 4,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 4,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 45,
        ["sortOrder"] = 1,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.8,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 14,
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
        [1] = "ANTI_SURFACE",
        [2] = "BOT",
        [3] = "BUILDABLE_BY_T1_FACTORY",
        [4] = "BUILDABLE_BY_T2_FACTORY",
        [5] = "BUILDABLE_BY_T3_FACTORY",
        [6] = "DIRECT_FIRE",
        [7] = "EDA",
        [8] = "LAND",
        [9] = "MOBILE",
        [10] = "RAIDER",
        [11] = "TECH1",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BOT",
        [14] = "SCFA_BUILTBYTIER1FACTORY",
        [15] = "SCFA_BUILTBYTIER2FACTORY",
        [16] = "SCFA_BUILTBYTIER3FACTORY",
        [17] = "SCFA_DIRECTFIRE",
        [18] = "SCFA_LAND",
        [19] = "SCFA_MOBILE",
        [20] = "SCFA_OVERLAYDIRECTFIRE",
        [21] = "SCFA_PRODUCTSC1",
        [22] = "SCFA_RECLAIMABLE",
        [23] = "SCFA_SELECTABLE",
        [24] = "SCFA_TECH1",
        [25] = "SCFA_UEF",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1002/LOD0/uel1002.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimCargoUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1002/LOD0/uel1002.sananimation",
            },
            ["death01"] = {
                ["clipName"] = "AnimDeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1002/LOD0/uel1002.sananimation",
            },
            ["death02"] = {
                ["clipName"] = "AnimDeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1002/LOD0/uel1002.sananimation",
            },
            ["fold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel1002/LOD0/uel1002.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.8,
                ["clipName"] = "AnimWalk01",
                ["sanAnimationPath"] = "Units/uel1002/LOD0/uel1002.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["walk"] = {
                ["clipName"] = "AnimIdle01",
                ["sanAnimationPath"] = "Units/uel1002/LOD0/uel1002.sananimation",
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
                    ["audioName"] = "EDA_UnitExplosions_Random",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.44999999999999996,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.408,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.46799999999999997,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.552,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.54,
                    ["z"] = 0.108,
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
                ["y"] = 0.3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Arm_Right_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Arm_Right_B02",
                    ["pitchMax"] = 120,
                    ["pitchMin"] = -120,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 10,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
                [2] = {
                    ["aimBone"] = "Arm_Left_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Arm_Left_B02",
                    ["pitchMax"] = 120,
                    ["pitchMin"] = -120,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 10,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Arm_Left_B01",
                    ["yawMax"] = 45,
                    ["yawMin"] = -45,
                    ["yawSpeed"] = 180,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom1112",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 7,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uel1002/muzzle_armcannonturret.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
                [4] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Arm_Right_Muzzle",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Arm_Left_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Arm_Left_Muzzle"] = {
                    ["aimController"] = "Arm_Left_Muzzle",
                },
                ["Arm_Right_Muzzle"] = {
                    ["aimController"] = "Arm_Right_Muzzle",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "peu106m",
            ["rangeMax"] = 14,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 0.3333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "8b7851d08f385f9ecd28d546d7cb601ced695eb66eeabfb08b01ac4427a7277d",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ArmCannonTurret",
                ["sourceProjectile"] = "/projectiles/TDFMachineGun01/TDFMachineGun01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ArmCannonTurret",
            },
            ["targetCheckInterval"] = 0.66,
            ["targetWaterLimits"] = "Above",
        },
    },
}
