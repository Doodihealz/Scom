-- uen3004: Tier 3: Ace
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "29E86162A1A40C65B1EABE12C7124BBFD04B19C99306501E77DCB8F67FF6CFA5",
            ["sourceId"] = "UES0304",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.05,
            ["targetId"] = "uen3004",
            ["textureResolution"] = 2048,
        },
        ["scoFieldFixPrefabCompletion"] = "1.0.1",
        ["scoSourceInterception"] = {
            ["silo"] = {
                ["autoIntercept"] = false,
                ["buildPower"] = 1080,
                ["buildTime"] = 324000,
                ["charge"] = 1,
                ["cost"] = {
                    ["alloys"] = 15000,
                    ["energy"] = 1800000,
                },
                ["cycleReload"] = 0,
                ["damage"] = 0,
                ["damageRadius"] = 0,
                ["deployDuration"] = 1,
                ["deployKey"] = "sco_source_launch",
                ["deployRate"] = 1,
                ["hatch"] = {
                    ["acceleration"] = 90,
                    ["axis"] = "z",
                    ["bones"] = {
                        [1] = "Center_Hatch01",
                        [2] = "Center_Hatch02",
                    },
                    ["goal"] = 90,
                    ["initialSpeed"] = 90,
                    ["targetSpeed"] = 90,
                },
                ["initialAmmo"] = 0,
                ["maxAmmo"] = 3,
                ["muzzleVelocity"] = 0,
                ["muzzles"] = {
                    [1] = "Center_Projectile01",
                    [2] = "Center_Projectile02",
                },
                ["nukeRings"] = {
                    [1] = {
                        ["damage"] = 70000,
                        ["radius"] = 30,
                        ["ticks"] = 24,
                        ["totalTime"] = 0,
                    },
                    [2] = {
                        ["damage"] = 500,
                        ["radius"] = 40,
                        ["ticks"] = 20,
                        ["totalTime"] = 0,
                    },
                },
                ["preserveAttack"] = true,
                ["projectile"] = "psf0180",
                ["rangeMax"] = 1024,
                ["rangeMin"] = 128,
                ["reload"] = 1,
                ["repackTimeout"] = 1,
                ["role"] = "launcher",
                ["sourceId"] = "UES0304",
                ["sourceLabel"] = "NukeMissiles",
                ["sourceStockpile"] = true,
                ["version"] = "1.0.0",
            },
            ["sourceId"] = "UES0304",
            ["targetId"] = "uen3004",
            ["weapons"] = {
                ["NukeMissiles"] = {
                    ["counted"] = true,
                    ["damage"] = 0,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 0,
                    ["muzzles"] = {
                        [1] = "Center_Projectile01",
                        [2] = "Center_Projectile02",
                    },
                    ["projectile"] = "psf0180",
                    ["rangeMax"] = 1024,
                    ["rangeMin"] = 128,
                    ["reload"] = 1,
                    ["sourceIndex"] = 2,
                    ["sourceLabel"] = "NukeMissiles",
                },
            },
        },
        ["scoTactical"] = {
            ["autoIntercept"] = false,
            ["buildPower"] = 1080,
            ["buildTime"] = 324000,
            ["charge"] = 1,
            ["cost"] = {
                ["alloys"] = 15000,
                ["energy"] = 1800000,
            },
            ["cycleReload"] = 0,
            ["damage"] = 0,
            ["damageRadius"] = 0,
            ["deployDuration"] = 1,
            ["deployKey"] = "sco_source_launch",
            ["deployRate"] = 1,
            ["hatch"] = {
                ["acceleration"] = 90,
                ["axis"] = "z",
                ["bones"] = {
                    [1] = "Center_Hatch01",
                    [2] = "Center_Hatch02",
                },
                ["goal"] = 90,
                ["initialSpeed"] = 90,
                ["targetSpeed"] = 90,
            },
            ["initialAmmo"] = 0,
            ["maxAmmo"] = 3,
            ["muzzleVelocity"] = 0,
            ["muzzles"] = {
                [1] = "Center_Projectile01",
                [2] = "Center_Projectile02",
            },
            ["nukeRings"] = {
                [1] = {
                    ["damage"] = 70000,
                    ["radius"] = 30,
                    ["ticks"] = 24,
                    ["totalTime"] = 0,
                },
                [2] = {
                    ["damage"] = 500,
                    ["radius"] = 40,
                    ["ticks"] = 20,
                    ["totalTime"] = 0,
                },
            },
            ["preserveAttack"] = true,
            ["projectile"] = "psf0180",
            ["rangeMax"] = 1024,
            ["rangeMin"] = 128,
            ["reload"] = 1,
            ["repackTimeout"] = 1,
            ["role"] = "launcher",
            ["sourceId"] = "UES0304",
            ["sourceLabel"] = "NukeMissiles",
            ["sourceStockpile"] = true,
            ["version"] = "1.0.0",
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "UES0304",
            ["targetId"] = "uen3004",
        },
        ["seaParityUnsupported"] = {
            ["nukeSilo"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.025,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 2.2,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.025,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.7,
            ["z"] = 3.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 1080,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4000,
            ["regen"] = 0,
            ["value"] = 4000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 20000,
        ["cost"] = {
            ["alloys"] = 10000,
            ["energy"] = 800000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDANavalUnit",
        },
        ["displayName"] = "Tier 3: Ace",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Ace",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["ManualFire1"] = true,
            ["ManualFire2"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "uen3004",
    },
    ["intel"] = {
        ["radarRadius"] = 0,
        ["sonarRadius"] = 60,
        ["visionRadius"] = 16,
    },
    ["movement"] = {
        ["acceleration"] = 3.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Submarine",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Submarine",
        },
        ["deceleration"] = 3.5,
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.025,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
                ["z"] = 3.5,
            },
        },
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = -2,
        ["referenceAltitude"] = "Water",
        ["rotationSpeed"] = 50,
        ["sortOrder"] = 5,
        ["speed"] = 3.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "UnderWater",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
        [7] = {
            ["innerRadius"] = 20,
            ["outerRadius"] = 175,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_FACTORY",
        [2] = "EDA",
        [3] = "MOBILE",
        [4] = "NAVAL",
        [5] = "TECH3",
        [6] = "ANTI_SURFACE",
        [7] = "INDIRECT_FIRE",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3FACTORY",
        [10] = "SCFA_INDIRECTFIRE",
        [11] = "SCFA_MOBILE",
        [12] = "SCFA_NAVAL",
        [13] = "SCFA_NUKE",
        [14] = "SCFA_NUKESUB",
        [15] = "SCFA_OVERLAYINDIRECTFIRE",
        [16] = "SCFA_OVERLAYSONAR",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SHOWATTACKRETICLE",
        [21] = "SCFA_SILO",
        [22] = "SCFA_SUBMERSIBLE",
        [23] = "SCFA_TECH3",
        [24] = "SCFA_UEF",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_anima001_1"] = {
                ["clipName"] = "AnimA001",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen3004/LOD0/uen3004.sananimation",
            },
            ["source_animadeath01_2"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen3004/LOD0/uen3004.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen3004/LOD0/uen3004.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.15,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.101,
                    ["z"] = 0.63,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.171,
                    ["z"] = 0.56,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.26899999999999996,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.25499999999999995,
                    ["z"] = 0.63,
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
                ["y"] = -0.025,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 2.2,
            },
            ["thickness"] = 0.32,
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
                [5] = {
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
                [6] = {
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
            },
            ["damage"] = 1500,
            ["damageRadius"] = 3,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen3004/muzzle_cruisemissiles.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Water",
                [2] = "WaterSurface",
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
                        [1] = "Right_Projectile01",
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
                        [1] = "Right_Projectile02",
                    },
                },
                [10] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile02",
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
                        [1] = "Right_Projectile03",
                    },
                },
                [14] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile03",
                    },
                },
                [15] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile03",
                    },
                },
                [16] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile01",
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
                        [1] = "Left_Projectile02",
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
                        [1] = "Left_Projectile03",
                    },
                },
                [30] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 1,
            ["muzzleSalvoSize"] = 5,
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
                ["Right_Projectile01"] = {
                    ["aimController"] = "Right_Projectile01",
                },
                ["Right_Projectile02"] = {
                    ["aimController"] = "Right_Projectile02",
                },
                ["Right_Projectile03"] = {
                    ["aimController"] = "Right_Projectile03",
                },
            },
            ["name"] = "CruiseMissiles",
            ["projectileLifetime"] = 50,
            ["projectileTemplate"] = "psf0161",
            ["rangeMax"] = 175,
            ["rangeMin"] = 20,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 20,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f1e400c41e23f21f6194442367aef4084254ab8d412a4e7b151c3d9fd46e8cef",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissiles",
                ["sourceProjectile"] = "/projectiles/TIFMissileCruise02/TIFMissileCruise02_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissiles",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {},
            ["collideFriendly"] = false,
            ["damage"] = 0,
            ["damageFriendly"] = true,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen3004/muzzle_nukemissiles.sanvfx",
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
                        [1] = "Center_Projectile01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Center_Projectile02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {},
            ["name"] = "NukeMissiles",
            ["projectileLifetime"] = 10,
            ["projectileTemplate"] = "psf0180",
            ["rangeMax"] = 1024,
            ["rangeMin"] = 128,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 1,
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "29e86162a1a40c65b1eabe12c7124bbfd04b19c99306501e77dcb8f67ff6cfa5",
                ["sourceId"] = "UES0304",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "NukeMissiles",
            },
            ["scoFaSourceWeapon"] = {
                ["AboveWaterTargetsOnly"] = true,
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "URLWeapon",
                        ["Cue"] = "URB2305_Missile_Cruise",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["CollideFriendly"] = false,
                ["CountedProjectile"] = true,
                ["Damage"] = 0,
                ["DamageFriendly"] = true,
                ["DamageRadius"] = 0,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Nuclear Warhead",
                ["FireTargetLayerCapsTable"] = {
                    ["Sub"] = "Land|Water|Seabed",
                    ["Water"] = "Land|Water|Seabed",
                },
                ["FiringTolerance"] = 2,
                ["InitialProjectileStorage"] = 0,
                ["Label"] = "NukeMissiles",
                ["ManualFire"] = 1,
                ["MaxProjectileStorage"] = 3,
                ["MaxRadius"] = 1024,
                ["MinRadius"] = 128,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["MuzzleVelocity"] = 0,
                ["NukeInnerRingDamage"] = 70000,
                ["NukeInnerRingRadius"] = 30,
                ["NukeInnerRingTicks"] = 24,
                ["NukeInnerRingTotalTime"] = 0,
                ["NukeOuterRingDamage"] = 500,
                ["NukeOuterRingRadius"] = 40,
                ["NukeOuterRingTicks"] = 20,
                ["NukeOuterRingTotalTime"] = 0,
                ["NukeWeapon"] = true,
                ["ProjectileId"] = "/projectiles/TIFMissileNuke02/TIFMissileNuke02_proj.bp",
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Center_Projectile01",
                        },
                        ["RackBone"] = "Center_Hatch01",
                    },
                    [2] = {
                        ["MuzzleBones"] = {
                            [1] = "Center_Projectile02",
                        },
                        ["RackBone"] = "Center_Hatch02",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 0,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RateOfFire"] = 1,
                ["TargetCheckInterval"] = 0.5,
                ["TargetRestrictDisallow"] = "UNTARGETABLE",
                ["WeaponCategory"] = "Missile",
            },
            ["scoFaSourceWeaponIndex"] = 2,
            ["scoSourceInterceptionLabel"] = "NukeMissiles",
            ["scoTacticalOwned"] = true,
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoTactical"] = UnitTemplate["additions"]["scoSourceInterception"]["silo"]
