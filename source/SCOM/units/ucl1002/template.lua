-- ucl1002: Flare
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
                    ["visionRadius"] = 18,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.6,
                    ["z"] = 0.6,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0106/UAL0106_unit.bp",
            ["sourceBlueprintSha256"] = "0a90859fa334b0689927356349f8d462b4596c9782c02cfd8a419f144f0b3e06",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BOT",
                [3] = "BUILTBYTIER1FACTORY",
                [4] = "BUILTBYTIER2FACTORY",
                [5] = "BUILTBYTIER3FACTORY",
                [6] = "DIRECTFIRE",
                [7] = "LAND",
                [8] = "MOBILE",
                [9] = "OVERLAYDIRECTFIRE",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "TECH1",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 2,
            ["sourceId"] = "UAL0106",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 4,
            ["sourceMotionType"] = "RULEUMT_Land",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl1002",
            ["weapons"] = {
                [1] = {
                    ["label"] = "ArmLaserTurret",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 3,
                    ["rackFireTogether"] = true,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret",
                                [2] = "Turret",
                                [3] = "Turret",
                            },
                            ["rackBone"] = "Turret",
                        },
                    },
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Direct Fire",
                    ["sourceProjectile"] = "/projectiles/ADFSonicPulsar01/ADFSonicPulsar01_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0.00032588005065917967,
                [2] = 0.4026573194208144,
                [3] = -0.0077442323802299744,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["foldDuration"] = 1.899999976158142,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0106",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 112997,
                ["entry"] = "units/UAL0106/UAL0106_LOD0.scm",
                ["sha256"] = "d86f56ef4f92109339e2318923a72b89394aaf45f3211b121c6b21e42ac64aa4",
            },
            ["unfoldDuration"] = 1.899999976158142,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Leg_Left_B02",
                    ["contactOffset"] = {
                        ["x"] = 0.002393556460738175,
                        ["y"] = -0.04794095361663679,
                        ["z"] = 0.030168866859325544,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = -1.2644054550027146e-06,
                        ["z"] = 0.9999999999992006,
                    },
                    ["length"] = 0.03230496635660529,
                    ["liftHeight"] = 0.07344324200773969,
                    ["minimumHeight"] = -0.012413540424720447,
                    ["plantHeight"] = 0.03258645957527955,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.06580984964966774,
                },
                [2] = {
                    ["boneName"] = "Leg_Right_B02",
                    ["contactOffset"] = {
                        ["x"] = -0.002393554672598844,
                        ["y"] = -0.04794090738288171,
                        ["z"] = 0.030168911751875076,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = -3.371748107383418e-07,
                        ["z"] = 0.9999999999999432,
                    },
                    ["length"] = 0.03230499615892768,
                    ["liftHeight"] = 0.0384743626301484,
                    ["minimumHeight"] = -0.049137451906613165,
                    ["plantHeight"] = -0.004137451906613167,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.06580984964966774,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ucl1002/LOD0/ucl1002_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ucl1002",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "UAL0106",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 1.100000023841858,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.25,
                    ["rateMin"] = 0.75,
                    ["weight"] = 10,
                },
                [2] = {
                    ["durationSeconds"] = 1.100000023841858,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1.25,
                    ["rateMin"] = 0.75,
                    ["weight"] = 90,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
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
            ["max"] = 70,
            ["regen"] = 0,
            ["value"] = 70,
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
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Flare",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Flare",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucl1002",
        ["unitTypeName"] = "Flare",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
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
        ["rotationSpeed"] = 45,
        ["sortOrder"] = 1,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 2,
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
        [1] = "BOT",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CHOSEN",
        [6] = "DIRECT_FIRE",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH1",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BOT",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_DIRECTFIRE",
        [17] = "SCFA_LAND",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_OVERLAYDIRECTFIRE",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimCargoUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 2,
                ["clipName"] = "AnimWalk",
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["source_animaidle01"] = {
                ["clipName"] = "AnimAidle01",
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["source_animfold"] = {
                ["clipName"] = "AnimFold",
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl1002/LOD0/ucl1002.sananimation",
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
            ["lod1distance"] = 171,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.3,
                ["z"] = 0,
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
                    ["aimBone"] = "Turret",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -60,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 7,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl1002/muzzle_armlaserturret.sanvfx",
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
                        [1] = "Turret",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret"] = {
                    ["aimController"] = "Turret",
                },
            },
            ["projectileLifetime"] = 0.644,
            ["projectileTemplate"] = "psf0070",
            ["rangeMax"] = 14,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "b2045b5e5c6c004428e46ef08de8a7269e53b9e20b4a71c366c3ed6fcf00866e",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ArmLaserTurret",
                ["sourceProjectile"] = "/projectiles/ADFSonicPulsar01/ADFSonicPulsar01_proj.bp",
            },
            ["scoSourceCategory"] = "Direct Fire",
            ["scoSourceLabel"] = "ArmLaserTurret",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ArmLaserTurret",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
