-- usn1001: Hau-esel
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["seaParityWeaponSemantics"] = {
            ["AntiAir"] = true,
            ["MainGun"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 2.75,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 23.33333396911621,
                ["key"] = "source_animadeath01",
                ["rateMaxTenths"] = 12,
                ["rateMinTenths"] = 8,
                ["weight"] = 100,
            },
            [2] = {
                ["durationSeconds"] = 23.33333396911621,
                ["key"] = "source_animadeath02",
                ["rateMaxTenths"] = 12,
                ["rateMinTenths"] = 8,
                ["weight"] = 100,
            },
            [3] = {
                ["durationSeconds"] = 23.33333396911621,
                ["key"] = "source_animadeath03",
                ["rateMaxTenths"] = 12,
                ["rateMinTenths"] = 8,
                ["weight"] = 100,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod3110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.175,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 1.1,
            ["z"] = 4.3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2000,
            ["regen"] = 0,
            ["value"] = 2000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1350,
        ["cost"] = {
            ["alloys"] = 270,
            ["energy"] = 2700,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimNavalUnit",
        },
        ["displayName"] = "Hau-esel",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Hau-esel",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 583.6,
            ["WaterSurface"] = 635.2,
        },
        ["tpId"] = "usn1001",
        ["unitTypeName"] = "UnknownT1Frigate",
    },
    ["intel"] = {
        ["radarRadius"] = 80,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 6,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 6,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 60,
        ["sortOrder"] = 1,
        ["speed"] = 6,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 80,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 48,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
    },
    ["tags"] = {
        [1] = "ANTI_SURFACE",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "DIRECT_FIRE",
        [6] = "FRIGATE",
        [7] = "MOBILE",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ANTINAVY",
        [10] = "SCFA_BUILTBYTIER1FACTORY",
        [11] = "SCFA_BUILTBYTIER2FACTORY",
        [12] = "SCFA_BUILTBYTIER3FACTORY",
        [13] = "SCFA_FRIGATE",
        [14] = "SCFA_INTELLIGENCE",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_NAVAL",
        [17] = "SCFA_OVERLAYANTIAIR",
        [18] = "SCFA_OVERLAYDIRECTFIRE",
        [19] = "SCFA_OVERLAYRADAR",
        [20] = "SCFA_OVERLAYSONAR",
        [21] = "SCFA_PRODUCTFA",
        [22] = "SCFA_RADAR",
        [23] = "SCFA_RECLAIMABLE",
        [24] = "SCFA_SELECTABLE",
        [25] = "SCFA_SERAPHIM",
        [26] = "SCFA_SONAR",
        [27] = "SCFA_TECH1",
        [28] = "SCFA_VISIBLETORECON",
        [29] = "SERAPHIM",
        [30] = "TECH1",
        [31] = "NAVAL",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usn1001/LOD0/usn1001.sananimation",
            },
            ["source_animadeath02"] = {
                ["clipName"] = "AnimAdeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usn1001/LOD0/usn1001.sananimation",
            },
            ["source_animadeath03"] = {
                ["clipName"] = "AnimAdeath03",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usn1001/LOD0/usn1001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usn1001/LOD0/usn1001.sananimation",
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
                    ["audioName"] = "chosen_unit_death_small",
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
                    ["x"] = 0.108,
                    ["y"] = 0.45,
                    ["z"] = -0.86,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.373,
                    ["z"] = 0.7739999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.48300000000000004,
                    ["z"] = 0.688,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.637,
                    ["z"] = -0.86,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.615,
                    ["z"] = 0.7739999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 73,
            ["lod1distance"] = 190,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 2.75,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Back_Turret_Muzzle03",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Back_Turret_Barrel",
                    ["pitchMax"] = 30,
                    ["pitchMin"] = -5,
                    ["pitchSpeed"] = 40,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Back_Turret",
                    ["yawMax"] = 110,
                    ["yawMin"] = -110,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 20,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usn1001/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret_Muzzle01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret_Muzzle02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Back_Turret_Muzzle03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.25,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Back_Turret_Muzzle01"] = {
                    ["aimController"] = "Back_Turret_Muzzle03",
                },
                ["Back_Turret_Muzzle02"] = {
                    ["aimController"] = "Back_Turret_Muzzle03",
                },
                ["Back_Turret_Muzzle03"] = {
                    ["aimController"] = "Back_Turret_Muzzle03",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0133",
            ["rangeMax"] = 28,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1.11111111111111,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "702176c2ca90064b2b972b8d779d8b7f8b23441a21de02620f99aa8cb12d03a2",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/SDFShieeihAutoCannon01/SDFShieeihAutoCannon01_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceLabel"] = "MainGun",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Front_Turret_Muzzle02",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Front_Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Front_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 2,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usn1001/muzzle_antiair.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Front_Turret_Muzzle01",
                        [2] = "Front_Turret_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Front_Turret_Muzzle01"] = {
                    ["aimController"] = "Front_Turret_Muzzle02",
                },
                ["Front_Turret_Muzzle02"] = {
                    ["aimController"] = "Front_Turret_Muzzle02",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0113",
            ["rangeMax"] = 48,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "9539620fea362f051a424ba168d0bb2efc9887e1a522037fd2a7f579f0a7c3c6",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AntiAir",
                ["sourceProjectile"] = "/projectiles/SAAShleoAAGatlingGun05/SAAShleoAAGatlingGun05_proj.bp",
            },
            ["scoSourceLabel"] = "AntiAir",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AntiAir",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
