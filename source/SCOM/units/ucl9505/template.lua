-- ucl9505: Tier 5: Chosen Hovertank (Kiss of Death)
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1450",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1042",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 15,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 18,
            ["y"] = 20,
            ["z"] = 27,
        },
        ["targetBones"] = {
            [1] = "Turret01_Yaw01",
            [2] = "Turret02_Yaw01",
            [3] = "Turret06_Yaw01",
            [4] = "Turret09_Yaw01",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1000000,
            ["value"] = 1000000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400000,
        ["cost"] = {
            ["alloys"] = 400000,
            ["energy"] = 4000000,
        },
    },
    ["footprint"] = {
        ["x"] = 18.4,
        ["y"] = 18.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "ChosenLandUnit",
        },
        ["displayName"] = "Tier 5: Chosen Hovertank (Kiss of Death)",
        ["icon"] = {
            ["shape"] = "experimental2",
            ["symbol"] = "none",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_experimental2_none.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "amphibious",
        ["name"] = "Kiss of Death",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 21843.9,
            ["Land"] = 80952.6,
            ["WaterSurface"] = 80952.6,
        },
        ["tpId"] = "ucl9505",
        ["unitTypeName"] = "ChosenT4Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 60,
    },
    ["movement"] = {
        ["acceleration"] = 1.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandLarge",
            [2] = "SeabedLarge",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandLarge",
            [2] = "SeabedLarge",
        },
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 18,
                ["y"] = 0.5,
                ["z"] = 27,
            },
        },
        ["mass"] = 0,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 20,
        ["sortOrder"] = 1,
        ["speed"] = 1.5,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsSeabed",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 70,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 50,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
    },
    ["skirtSize"] = {
        ["x"] = 30,
        ["y"] = 30,
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "ANTI_SURFACE",
        [3] = "BOT",
        [4] = "CHOSEN",
        [5] = "DIRECT_FIRE",
        [6] = "LAND",
        [7] = "MOBILE",
        [8] = "SEABED",
        [9] = "TECH4",
    },
    ["visuals"] = {
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
                ["boneName"] = "Root",
                ["particleName"] = "VFX/Unit/vcu5521_ucl4005_ground_levitation.sanvfx",
            },
            [2] = {
                ["boneName"] = "Root",
                ["particleName"] = "VFX/Unit/vcu5522_ucl4005_surface_effects.sanvfx",
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 346,
            ["lod1distance"] = 900,
        },
        ["selection"] = {
            ["size"] = {
                ["x"] = 33,
                ["y"] = 33,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret01_Muzzle01",
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret01_Pitch01",
                    ["pitchMax"] = 30,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 20,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 60,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Root",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 5,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom5140",
                },
            },
            ["damage"] = 12000,
            ["damageRadius"] = 9,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm1341_cannon_artillery_large_muzzle.sanvfx",
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
                        [1] = "Turret01_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "pcd412",
            ["rangeMax"] = 70,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 12,
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret02_Muzzle01",
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret02_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret02_Yaw01",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 100,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["name"] = "chosen_cannon_plasma_fire_small",
                },
            },
            ["damage"] = 30,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret02_Muzzle01",
                        [2] = "Turret02_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "pcd111",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.4,
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret03_Muzzle01",
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret03_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret03_Yaw01",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 100,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["name"] = "chosen_cannon_plasma_fire_small",
                },
            },
            ["damage"] = 30,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret03_Muzzle01",
                        [2] = "Turret03_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "pcd111",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.4,
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret04_Muzzle01",
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret04_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret04_Yaw01",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 100,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["name"] = "chosen_cannon_plasma_fire_small",
                },
            },
            ["damage"] = 30,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm3121_cannon_antiair_small_muzzle.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret03_Muzzle01",
                        [2] = "Turret03_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "pcd111",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.4,
            ["targetWaterLimits"] = "Above",
        },
        [5] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret05_Muzzle01",
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret05_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret05_Yaw01",
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
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 0.1,
                ["fadeOutTime"] = 0.6,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_01.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_02.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 5,
            ["damage"] = 160,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx",
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
                        [1] = "Turret05_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["projectileTemplate"] = "pcd171",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["targetWaterLimits"] = "Above",
        },
        [6] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret06_Muzzle01",
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret06_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret06_Yaw01",
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
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 0.1,
                ["fadeOutTime"] = 0.6,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_01.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_02.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 5,
            ["damage"] = 160,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx",
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
                        [1] = "Turret06_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["projectileTemplate"] = "pcd171",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["targetWaterLimits"] = "Above",
        },
        [7] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret07_Muzzle01",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret07_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret07_Yaw01",
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
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 0.1,
                ["fadeOutTime"] = 0.6,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_01.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_02.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 5,
            ["damage"] = 160,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx",
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
                        [1] = "Turret07_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["projectileTemplate"] = "pcd171",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["targetWaterLimits"] = "Above",
        },
        [8] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret08_Muzzle01",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret08_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret08_Yaw01",
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
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 0.1,
                ["fadeOutTime"] = 0.6,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_01.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_02.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 5,
            ["damage"] = 160,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx",
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
                        [1] = "Turret08_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["projectileTemplate"] = "pcd171",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["targetWaterLimits"] = "Above",
        },
        [9] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret09_Muzzle01",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret09_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret09_Yaw01",
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
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 0.1,
                ["fadeOutTime"] = 0.6,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_01.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_02.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 5,
            ["damage"] = 160,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx",
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
                        [1] = "Turret09_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["projectileTemplate"] = "pcd171",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["targetWaterLimits"] = "Above",
        },
        [10] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret010_Muzzle01",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret010_Pitch01",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 50,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret010_Yaw01",
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
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 0.1,
                ["fadeOutTime"] = 0.6,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_01.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/Materials/Beam/Beam ucs1001_02.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 5,
            ["damage"] = 160,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm7101_beam_antitank_small_muzzle.sanvfx",
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
                        [1] = "Turret010_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["projectileTemplate"] = "pcd171",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["targetWaterLimits"] = "Above",
        },
        [11] = {
            ["audio"] = {
                ["onCharge"] = {
                    ["looping"] = false,
                    ["name"] = "acom0155",
                },
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom0150",
                },
            },
            ["category"] = "AOEPulse",
            ["chargeTime"] = 2,
            ["damage"] = 12000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 10,
            ["damageType"] = "Normal",
            ["reloadTime"] = 22,
            ["useDamageCollider"] = true,
        },
    },
}
