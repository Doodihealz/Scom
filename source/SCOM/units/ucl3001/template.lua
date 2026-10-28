-- ucl3001: Harbinger Mark IV
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 22,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1.2,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = true,
                ["energyDrainRechargeTime"] = 5,
                ["maxHealth"] = 1300,
                ["rechargeTime"] = 60,
                ["regenRate"] = 9,
                ["regenStartTime"] = 3,
                ["runtimeRadius"] = 1.25,
                ["size"] = 2.5,
                ["verticalOffset"] = 0,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0303/UAL0303_unit.bp",
            ["sourceBlueprintSha256"] = "699d3ac2d7cecd9e7990b31328b4af069511eda4dddeae08971eb60c063d606b",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BOT",
                [3] = "BUILTBYTIER3FACTORY",
                [4] = "DIRECTFIRE",
                [5] = "LAND",
                [6] = "MOBILE",
                [7] = "OVERLAYDIRECTFIRE",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIM",
                [10] = "RECLAIMABLE",
                [11] = "REPAIR",
                [12] = "SELECTABLE",
                [13] = "TECH3",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAL0303",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 3,
            ["sourceMotionType"] = "RULEUMT_Land",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl3001",
            ["weapons"] = {
                [1] = {
                    ["label"] = "FrontTurret01",
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
                    ["rateOfFire"] = 1.25,
                    ["reloadTime"] = 0.8,
                    ["sourceCategory"] = "Direct Fire",
                    ["sourceProjectile"] = "/projectiles/ADFLaserHighIntensity01/ADFLaserHighIntensity01_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -0.00010921061038970946,
                [2] = 1.582750616073608,
                [3] = 2.6802356907207955e-09,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["foldDuration"] = 2.5,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0303",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 178375,
                ["entry"] = "units/UAL0303/UAL0303_lod0.scm",
                ["sha256"] = "1f1065e499e22a92824c8bd7aa1eb5ef9cbfcc8c5b811b099106447a39982d2f",
            },
            ["unfoldDuration"] = 2.5,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Leg01_B03",
                    ["contactOffset"] = {
                        ["x"] = -7.374549676662464e-09,
                        ["y"] = -0.9754635978913213,
                        ["z"] = 0.1620036068767401,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.7071070416417562,
                        ["y"] = -0.06162797240833492,
                        ["z"] = 0.7044158038243331,
                    },
                    ["length"] = 0.04564356803894043,
                    ["liftHeight"] = 0.15133579970773078,
                    ["minimumHeight"] = -0.023986004770219366,
                    ["plantHeight"] = 0.021013995229780633,
                    ["right"] = {
                        ["x"] = 0.7071065207312105,
                        ["y"] = -0.06162832000638018,
                        ["z"] = 0.7044162963139009,
                    },
                    ["width"] = 0.04564356803894043,
                },
                [2] = {
                    ["boneName"] = "Leg02_B03",
                    ["contactOffset"] = {
                        ["x"] = -3.4378032764400624e-09,
                        ["y"] = -0.9754635465696591,
                        ["z"] = 0.16200369547844007,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.7071066828599809,
                        ["y"] = 0.06162799839708637,
                        ["z"] = -0.7044161617029545,
                    },
                    ["length"] = 0.04564356803894043,
                    ["liftHeight"] = 0.22878378094383567,
                    ["minimumHeight"] = -0.021763927872037042,
                    ["plantHeight"] = 0.023236072127962956,
                    ["right"] = {
                        ["x"] = -0.7071068795130722,
                        ["y"] = -0.06162826272256619,
                        ["z"] = 0.7044159411733127,
                    },
                    ["width"] = 0.04564368724822998,
                },
                [3] = {
                    ["boneName"] = "Leg03_B03",
                    ["contactOffset"] = {
                        ["x"] = 1.5605842222379482e-07,
                        ["y"] = -0.9754635638222654,
                        ["z"] = 0.16200378694348805,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.7071067191150897,
                        ["y"] = -0.06162772426169408,
                        ["z"] = 0.7044161492928865,
                    },
                    ["length"] = 0.045643627643585205,
                    ["liftHeight"] = 0.14879859714039154,
                    ["minimumHeight"] = -0.018969083255579305,
                    ["plantHeight"] = 0.026030916744420693,
                    ["right"] = {
                        ["x"] = 0.7071068432579957,
                        ["y"] = 0.06162760499196532,
                        ["z"] = -0.7044160351104074,
                    },
                    ["width"] = 0.045643627643585205,
                },
                [4] = {
                    ["boneName"] = "Leg04_B03",
                    ["contactOffset"] = {
                        ["x"] = -5.417485565240108e-10,
                        ["y"] = -0.9754635859412331,
                        ["z"] = 0.1620036310367482,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.7071068327947316,
                        ["y"] = 0.06162798673962555,
                        ["z"] = -0.7044160122153837,
                    },
                    ["length"] = 0.045643627643585205,
                    ["liftHeight"] = 0.14052943733465903,
                    ["minimumHeight"] = -0.03409853977760022,
                    ["plantHeight"] = 0.01090146022239978,
                    ["right"] = {
                        ["x"] = -0.7071067295783109,
                        ["y"] = 0.06162762625097248,
                        ["z"] = -0.7044161473644226,
                    },
                    ["width"] = 0.04564356803894043,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ucl3001/LOD0/ucl3001_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ucl3001",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "UAL0303",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 1.100000023841858,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 2,
                    ["rateMin"] = 1,
                    ["weight"] = 1,
                },
                [2] = {
                    ["durationSeconds"] = 1.100000023841858,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 2,
                    ["rateMin"] = 1,
                    ["weight"] = 1,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 0.85,
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
            ["y"] = 0.75,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1.5,
            ["z"] = 1.2,
        },
    },
    ["construction"] = {
        ["buildPower"] = 3,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4600,
            ["regen"] = 0,
            ["value"] = 4600,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["max"] = 1300,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["y"] = 0,
                },
                ["radii"] = {
                    ["x"] = 1.25,
                    ["y"] = 1.25,
                    ["z"] = 1.25,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 60,
                ["regen"] = 9,
                ["regenDelay"] = 3,
                ["scoDamageRechargeTime"] = 60,
                ["scoEnergyDrainRechargeTime"] = 5,
                ["scoFaHarbingerPersonalShield"] = true,
                ["scoManualRechargeTime"] = 5,
                ["type"] = 0,
                ["value"] = 1300,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 3600,
        ["cost"] = {
            ["alloys"] = 840,
            ["energy"] = 9600,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 25,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1.2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Harbinger Mark IV",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Harbinger Mark IV",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "ucl3001",
        ["unitTypeName"] = "Harbinger Mark IV",
    },
    ["intel"] = {
        ["visionRadius"] = 22,
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
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 1,
        ["speed"] = 3,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.3,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 22,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 22,
        },
    },
    ["tags"] = {
        [1] = "BOT",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "DIRECT_FIRE",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "SHIELD",
        [8] = "TECH3",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BOT",
        [12] = "SCFA_BUILTBYTIER3FACTORY",
        [13] = "SCFA_DIRECTFIRE",
        [14] = "SCFA_LAND",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_OVERLAYDIRECTFIRE",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIM",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_REPAIR",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_TECH3",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimCargoUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.3,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl3001/LOD0/ucl3001.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 1.125,
                    ["z"] = -0.24,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 1.02,
                    ["z"] = 0.216,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 1.17,
                    ["z"] = 0.192,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 1.38,
                    ["z"] = -0.24,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 1.35,
                    ["z"] = 0.216,
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
                ["y"] = 0.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 0.85,
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
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -40,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 300,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl3001/muzzle_frontturret01.sanvfx",
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
            ["projectileLifetime"] = 1.0733333333333333,
            ["projectileTemplate"] = "psf0058",
            ["rangeMax"] = 28,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.8,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "073f9de2a28a53abb9036077a5437f96b3cc7fd426f55431801e1a87dd545086",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "FrontTurret01",
                ["sourceProjectile"] = "/projectiles/ADFLaserHighIntensity01/ADFLaserHighIntensity01_proj.bp",
            },
            ["scoSourceCategory"] = "Direct Fire",
            ["scoSourceLabel"] = "FrontTurret01",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "FrontTurret01",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
