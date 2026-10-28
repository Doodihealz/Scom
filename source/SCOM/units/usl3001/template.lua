-- usl3001: Othuum
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -0.0029267120361328126,
                [2] = 0.5862318737164038,
                [3] = 0.05428757861041336,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0303",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 102284,
                ["entry"] = "units/XSL0303/XSL0303_lod0.scm",
                ["sha256"] = "91a9289a11358d3a9105f6bb20265ab02c5beba7768839f54cca6f1435404311",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/usl3001/LOD0/usl3001_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.48760607838630676,
                        ["y"] = -6.942398949214175e-05,
                        ["z"] = -0.0953211337245204,
                    },
                    ["width"] = 0.230485,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -2.9802322387695312e-08,
                        ["y"] = -1.4424279373183302e-07,
                        ["z"] = -0.6065586805343498,
                    },
                    ["width"] = 0.284125,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 2.2351741790771484e-08,
                        ["y"] = 1.2276303501534969e-07,
                        ["z"] = 0.7504358887672332,
                    },
                    ["width"] = 0.416562,
                },
                [4] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.48760607838630676,
                        ["y"] = -6.942398949214175e-05,
                        ["z"] = -0.0953211337245204,
                    },
                    ["width"] = 0.230485,
                },
            },
            ["unit"] = "usl3001",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 1.4,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1335",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1130",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.15,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.3,
            ["z"] = 1.8,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 6700,
            ["regen"] = 0,
            ["value"] = 6700,
        },
    },
    ["economy"] = {
        ["buildTime"] = 3600,
        ["cost"] = {
            ["alloys"] = 840,
            ["energy"] = 9600,
        },
    },
    ["footprint"] = {
        ["x"] = 0.7,
        ["y"] = 1.8,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Othuum",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Othuum",
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
            ["Land"] = 2424.1,
            ["WaterSurface"] = 1447.1,
        },
        ["tpId"] = "usl3001",
        ["unitTypeName"] = "UnknownT3Tank",
    },
    ["intel"] = {
        ["visionRadius"] = 22,
    },
    ["movement"] = {
        ["acceleration"] = 2.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "SeabedSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "SeabedSmall",
        },
        ["deceleration"] = 2.5,
        ["mass"] = 0,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 75,
        ["sortOrder"] = 1,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksSeabed",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 1,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
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
        [1] = "ANTI_SURFACE",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "DIRECT_FIRE",
        [4] = "MOBILE",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_BUILTBYTIER3FACTORY",
        [7] = "SCFA_DIRECTFIRE",
        [8] = "SCFA_LAND",
        [9] = "SCFA_MOBILE",
        [10] = "SCFA_OVERLAYANTINAVY",
        [11] = "SCFA_OVERLAYDIRECTFIRE",
        [12] = "SCFA_PRODUCTFA",
        [13] = "SCFA_RECLAIMABLE",
        [14] = "SCFA_SELECTABLE",
        [15] = "SCFA_SERAPHIM",
        [16] = "SCFA_TANK",
        [17] = "SCFA_TECH3",
        [18] = "SCFA_VISIBLETORECON",
        [19] = "SERAPHIM",
        [20] = "TANK",
        [21] = "TECH3",
        [22] = "LAND",
        [23] = "SEABED",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl3001/LOD0/usl3001.sananimation",
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
                    ["audioName"] = "eda_unit_death_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1301_death_land_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.22499999999999998,
                    ["z"] = -0.36000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.204,
                    ["z"] = 0.324,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.23399999999999999,
                    ["z"] = 0.28800000000000003,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.276,
                    ["z"] = -0.36000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.27,
                    ["z"] = 0.324,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 68,
            ["lod1distance"] = 177,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 1.4,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Barrel_Recoil_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 70,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom2130",
                },
            },
            ["damage"] = 400,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl3001/muzzle_mainturret.sanvfx",
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
                        [1] = "Turret_Barrel_Recoil_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.4,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Turret_Barrel_Recoil_Muzzle"] = {
                    ["aimController"] = "Turret_Barrel_Recoil_Muzzle",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0135",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "1e24de16c6af766f0bda9f3121af9eda545c73388f2cb9a69f6615942e6c6822",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainTurret",
                ["sourceProjectile"] = "/projectiles/SDFTauCannon01/SDFTauCannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainTurret",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Torpedo_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Torpedo_Muzzle",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Torpedo_Muzzle",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl3001/muzzle_torpedo01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Torpedo_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Torpedo_Muzzle"] = {
                    ["aimController"] = "Torpedo_Muzzle",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0118",
            ["rangeMax"] = 32,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "200b882a8eb86a1201167c89f1c9b8481bd290fcf734e738c7b7e4c2ba843730",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "Torpedo01",
                ["sourceProjectile"] = "/projectiles/SANUallCavitationTorpedo01/SANUallCavitationTorpedo01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "Torpedo01",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Below",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Turret_Barrel_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Turret",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Right_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 75,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {},
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
                        [1] = "Right_Turret_Barrel_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Turret_Barrel_Muzzle01"] = {
                    ["aimController"] = "Right_Turret_Barrel_Muzzle01",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0123",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "141d2ede744fd64456c5e21561c605e12f864cc73bd6b22e0d0e714cc424d05c",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "RightTurret",
                ["sourceProjectile"] = "/projectiles/SDFAireauBolter02/SDFAireauBolter02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "RightTurret",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Left_Turret_Barrel_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Left_Turret",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Left_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 75,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {},
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
                        [1] = "Left_Turret_Barrel_Muzzle01",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Left_Turret_Barrel_Muzzle01"] = {
                    ["aimController"] = "Left_Turret_Barrel_Muzzle01",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0123",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "141d2ede744fd64456c5e21561c605e12f864cc73bd6b22e0d0e714cc424d05c",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "LeftTurret",
                ["sourceProjectile"] = "/projectiles/SDFAireauBolter02/SDFAireauBolter02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "LeftTurret",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
