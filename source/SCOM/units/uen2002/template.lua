-- uen2002: Tier 2: Governor Class
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "128A02A5B77DC260BD3E4F2DD4F112C20380F08B978AC11776A72A2101EB29A4",
            ["sourceId"] = "UES0202",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.065,
            ["targetId"] = "uen2002",
            ["textureResolution"] = 2048,
        },
        ["scoFieldFixPrefabCompletion"] = "1.0.1",
        ["scoIdleResetLocomotion"] = true,
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "UES0202",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 23.33333396911621,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [2] = {
                    ["durationSeconds"] = 18.33333396911621,
                    ["key"] = "scoSourceDeath02",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
                [3] = {
                    ["durationSeconds"] = 33.29999923706055,
                    ["key"] = "scoSourceDeath03",
                    ["rateMax"] = 1,
                    ["rateMin"] = 1,
                    ["weight"] = 100,
                },
            },
        },
        ["scoSourceInterception"] = {
            ["sourceId"] = "UES0202",
            ["weapons"] = {
                ["PhalanxGun01"] = {
                    ["counted"] = false,
                    ["damage"] = 1,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 100,
                    ["muzzles"] = {
                        [1] = "Center_Turret_Muzzle",
                    },
                    ["projectile"] = "psf0037",
                    ["rangeMax"] = 50,
                    ["rangeMin"] = 0,
                    ["reload"] = 2,
                    ["sourceIndex"] = 4,
                    ["sourceLabel"] = "PhalanxGun01",
                    ["targetClass"] = "tactical",
                },
            },
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "UES0202",
            ["targetId"] = "uen2002",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.8,
                ["y"] = 3.75,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.375,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.6,
            ["y"] = 1.5,
            ["z"] = 6.2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2500,
            ["regen"] = 0,
            ["value"] = 2500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 8000,
        ["cost"] = {
            ["alloys"] = 2000,
            ["energy"] = 18000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDANavalUnit",
        },
        ["displayName"] = "Tier 2: Governor Class",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Governor Class",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uen2002",
    },
    ["intel"] = {
        ["radarRadius"] = 150,
        ["sonarRadius"] = 120,
        ["visionRadius"] = 65,
    },
    ["movement"] = {
        ["acceleration"] = 4.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 4.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 40,
        ["sortOrder"] = 5,
        ["speed"] = 4.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 150,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 120,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
        [7] = {
            ["innerRadius"] = 12.5,
            ["outerRadius"] = 150,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 75,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 65,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 65,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "EDA",
        [4] = "MOBILE",
        [5] = "NAVAL",
        [6] = "CRUISER",
        [7] = "TECH2",
        [8] = "ANTI_AIR",
        [9] = "ANTI_SURFACE",
        [10] = "DIRECT_FIRE",
        [11] = "INDIRECT_FIRE",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_ANTIAIR",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_CRUISER",
        [17] = "SCFA_INDIRECTFIRE",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_NAVAL",
        [20] = "SCFA_OVERLAYANTIAIR",
        [21] = "SCFA_OVERLAYDEFENSE",
        [22] = "SCFA_OVERLAYDIRECTFIRE",
        [23] = "SCFA_OVERLAYINDIRECTFIRE",
        [24] = "SCFA_OVERLAYRADAR",
        [25] = "SCFA_OVERLAYSONAR",
        [26] = "SCFA_PRODUCTSC1",
        [27] = "SCFA_RECLAIMABLE",
        [28] = "SCFA_SELECTABLE",
        [29] = "SCFA_SHOWATTACKRETICLE",
        [30] = "SCFA_SILO",
        [31] = "SCFA_TECH2",
        [32] = "SCFA_UEF",
        [33] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
            },
            ["scoSourceDeath02"] = {
                ["clipName"] = "AnimA001",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
            },
            ["scoSourceDeath03"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
            },
            ["source_anima001_1"] = {
                ["clipName"] = "AnimA001",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
            },
            ["source_anima002_2"] = {
                ["clipName"] = "AnimA002",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
            },
            ["source_animadeath01_3"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
            },
            ["source_animadeath02_4"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen2002/LOD0/uen2002.sananimation",
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.288,
                    ["y"] = 0.75,
                    ["z"] = -1.2400000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 0.645,
                    ["z"] = 1.1159999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.32000000000000006,
                    ["y"] = 0.795,
                    ["z"] = 0.9920000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.288,
                    ["y"] = 1.005,
                    ["z"] = -1.2400000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 0.9750000000000001,
                    ["z"] = 1.1159999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 150,
            ["lod1distance"] = 390,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.8,
                ["y"] = 3.75,
            },
            ["thickness"] = 0.2,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Projectile01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Projectile01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Projectile01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
                [2] = {
                    ["aimBone"] = "Right_Projectile02",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Projectile02",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Projectile02",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
                [3] = {
                    ["aimBone"] = "Right_Projectile03",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Projectile03",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Projectile03",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
                [4] = {
                    ["aimBone"] = "Right_Projectile04",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Projectile04",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Projectile04",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
                [5] = {
                    ["aimBone"] = "Left_Projectile01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Left_Projectile01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Projectile01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
                [6] = {
                    ["aimBone"] = "Left_Projectile02",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Left_Projectile02",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Projectile02",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
                [7] = {
                    ["aimBone"] = "Left_Projectile03",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Left_Projectile03",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Projectile03",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
                [8] = {
                    ["aimBone"] = "Left_Projectile04",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Left_Projectile04",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Projectile04",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 300,
            ["damageRadius"] = 3,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen2002/muzzle_cruisemissile.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile01",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile01",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile01",
                    },
                },
                [5] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile02",
                    },
                },
                [6] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile02",
                    },
                },
                [7] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile02",
                    },
                },
                [8] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile02",
                    },
                },
                [9] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile03",
                    },
                },
                [10] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile03",
                    },
                },
                [11] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile03",
                    },
                },
                [12] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile03",
                    },
                },
                [13] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile04",
                    },
                },
                [14] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile04",
                    },
                },
                [15] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile04",
                    },
                },
                [16] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile04",
                    },
                },
                [17] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile01",
                    },
                },
                [18] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile01",
                    },
                },
                [19] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile01",
                    },
                },
                [20] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile01",
                    },
                },
                [21] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile02",
                    },
                },
                [22] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile02",
                    },
                },
                [23] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile02",
                    },
                },
                [24] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile02",
                    },
                },
                [25] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile03",
                    },
                },
                [26] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile03",
                    },
                },
                [27] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile03",
                    },
                },
                [28] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile03",
                    },
                },
                [29] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile04",
                    },
                },
                [30] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile04",
                    },
                },
                [31] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile04",
                    },
                },
                [32] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 1.5,
            ["muzzleSalvoSize"] = 4,
            ["muzzles"] = {
                ["Left_Projectile01"] = {
                    ["aimController"] = "Left_Projectile01",
                },
                ["Left_Projectile02"] = {
                    ["aimController"] = "Left_Projectile02",
                },
                ["Left_Projectile03"] = {
                    ["aimController"] = "Left_Projectile03",
                },
                ["Left_Projectile04"] = {
                    ["aimController"] = "Left_Projectile04",
                },
                ["Right_Projectile01"] = {
                    ["aimController"] = "Right_Projectile01",
                },
                ["Right_Projectile02"] = {
                    ["aimController"] = "Right_Projectile02",
                },
                ["Right_Projectile03"] = {
                    ["aimController"] = "Right_Projectile03",
                },
                ["Right_Projectile04"] = {
                    ["aimController"] = "Right_Projectile04",
                },
            },
            ["name"] = "CruiseMissile",
            ["projectileLifetime"] = 20,
            ["projectileTemplate"] = "psf0162",
            ["rangeMax"] = 150,
            ["rangeMin"] = 12.5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 10,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "8c941c11aa418cb9dd8b3500dc772d112a54f43ed3460b5b179c94b6e5fac88d",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissile",
                ["sourceProjectile"] = "/projectiles/TIFMissileCruise04/TIFMissileCruise04_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissile",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Front_Turret01_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Front_Turret01_Barrel01",
                    ["pitchMax"] = 20,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Front_Turret01",
                    ["yawMax"] = 120,
                    ["yawMin"] = -120,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 200,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen2002/muzzle_frontturret01.sanvfx",
            },
            ["firingRandomness"] = 0.5,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Front_Turret01_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Front_Turret01_Muzzle"] = {
                    ["aimController"] = "Front_Turret01_Muzzle",
                },
            },
            ["name"] = "FrontTurret01",
            ["projectileLifetime"] = 4,
            ["projectileTemplate"] = "psf0151",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "7b4cf765e643ae78c849338be82943eaba000aa10d03565dcd717182aed63460",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "FrontTurret01",
                ["sourceProjectile"] = "/projectiles/TDFGauss01/TDFGauss01_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "FrontTurret01",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Back_Turret02_Projectile01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 10,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Back_Turret02",
                    ["pitchMax"] = 80,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Back_Turret02",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 250,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen2002/muzzle_backturret02.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret02_Projectile01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret02_Projectile02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret02_Projectile03",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret02_Projectile04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.4,
            ["muzzleSalvoSize"] = 4,
            ["muzzles"] = {
                ["Back_Turret02_Projectile01"] = {
                    ["aimController"] = "Back_Turret02_Projectile01",
                },
                ["Back_Turret02_Projectile02"] = {
                    ["aimController"] = "Back_Turret02_Projectile01",
                },
                ["Back_Turret02_Projectile03"] = {
                    ["aimController"] = "Back_Turret02_Projectile01",
                },
                ["Back_Turret02_Projectile04"] = {
                    ["aimController"] = "Back_Turret02_Projectile01",
                },
            },
            ["name"] = "BackTurret02",
            ["projectileLifetime"] = 4,
            ["projectileTemplate"] = "psf0146",
            ["rangeMax"] = 75,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "dd71f937eb2aeab35ae544fe8e104064ef9ef3b1c103cb05cd72a4c09e0d0f1e",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "BackTurret02",
                ["sourceProjectile"] = "/projectiles/TAAMissileFlayer02/TAAMissileFlayer02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "BackTurret02",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Center_Turret_Muzzle",
                    ["aimTolerance"] = 5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Center_Turret_Barrel",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 180,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Center_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 720,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 1,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen2002/muzzle_phalanxgun01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Center_Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Center_Turret_Muzzle"] = {
                    ["aimController"] = "Center_Turret_Muzzle",
                },
            },
            ["name"] = "PhalanxGun01",
            ["projectileLifetime"] = 10,
            ["projectileTemplate"] = "psf0037",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 2,
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "128a02a5b77dc260bd3e4f2dd4f112c20380f08b978ac11776a72a2101eb29a4",
                ["sourceId"] = "UES0202",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "PhalanxGun01",
            },
            ["scoFaSourceWeapon"] = {
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "UESWeapon",
                        ["Cue"] = "UES0202_Phalanx",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["Damage"] = 1,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Phalanx Anti Missile",
                ["FireTargetLayerCapsTable"] = {
                    ["Water"] = "Air",
                },
                ["FiringTolerance"] = 5,
                ["Label"] = "PhalanxGun01",
                ["MaxRadius"] = 50,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["MuzzleVelocity"] = 100,
                ["ProjectileId"] = "/projectiles/TDPhalanx01/TDPhalanx01_proj.bp",
                ["ProjectileLifetimeUsesMultiplier"] = 1.1,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Center_Turret_Muzzle",
                        },
                        ["RackBone"] = "Center_Turret_Barrel",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 10,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RangeCategory"] = "UWRC_Countermeasure",
                ["RateOfFire"] = 0.5,
                ["TargetCheckInterval"] = 0.5,
                ["TargetRestrictDisallow"] = "UNTARGETABLE,STRATEGIC",
                ["TargetRestrictOnlyAllow"] = "TACTICAL,MISSILE",
                ["TargetType"] = "RULEWTT_Projectile",
                ["TrackingRadius"] = 1.5,
                ["TurretBoneMuzzle"] = "Center_Turret_Muzzle",
                ["TurretBonePitch"] = "Center_Turret_Barrel",
                ["TurretBoneYaw"] = "Center_Turret",
                ["TurretDualManipulators"] = false,
                ["TurretPitch"] = 0,
                ["TurretPitchRange"] = 90,
                ["TurretPitchSpeed"] = 180,
                ["TurretYaw"] = 0,
                ["TurretYawRange"] = 180,
                ["TurretYawSpeed"] = 720,
                ["Turreted"] = true,
                ["WeaponCategory"] = "Defense",
                ["WeaponRepackTimeout"] = 0,
                ["WeaponUnpacks"] = true,
            },
            ["scoFaSourceWeaponIndex"] = 4,
            ["scoSourceInterceptionLabel"] = "PhalanxGun01",
            ["scoTacticalOwned"] = true,
        },
    },
}
