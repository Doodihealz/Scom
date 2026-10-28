-- usl2201: Iashavoh
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0.0012204236984252929,
                [2] = 0.8694592855543934,
                [3] = 0.0015241311069593443,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0205",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 77324,
                ["entry"] = "units/XSL0205/XSL0205_lod0.scm",
                ["sha256"] = "467304fb8b4c37e5e3aee215b7077d72091b211e39f802bc2b36c08d531f5aba",
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.8,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1.1666666269302368,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1220",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.35,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 0.7,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1000,
            ["regen"] = 0,
            ["value"] = 1000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 800,
        },
    },
    ["footprint"] = {
        ["x"] = 0.9,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Iashavoh",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "aa",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_antiAir.png",
        ["iconUIBuildSortPriority"] = 50,
        ["iconUIType"] = "land",
        ["name"] = "Iashavoh",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 564.3,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usl2201",
        ["unitTypeName"] = "UnknownT2MAA",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 3.6,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["deceleration"] = 3.6,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0.25,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 5,
        ["speed"] = 3.6,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 40,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "MOBILE",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_ANTIAIR",
        [7] = "SCFA_BUILTBYTIER2FACTORY",
        [8] = "SCFA_BUILTBYTIER3FACTORY",
        [9] = "SCFA_HOVER",
        [10] = "SCFA_LAND",
        [11] = "SCFA_MOBILE",
        [12] = "SCFA_OVERLAYANTIAIR",
        [13] = "SCFA_PRODUCTFA",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SERAPHIM",
        [17] = "SCFA_TECH2",
        [18] = "SCFA_VISIBLETORECON",
        [19] = "SERAPHIM",
        [20] = "TECH2",
        [21] = "HOVER",
        [22] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl2201/LOD0/usl2201.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl2201/LOD0/usl2201.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
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
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.5249999999999999,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.476,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.546,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.6439999999999999,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.6299999999999999,
                    ["z"] = 0.162,
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
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.8,
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
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 20,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 20,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 85,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom1121",
                },
            },
            ["damage"] = 72,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl2201/muzzle_aagun.sanvfx",
            },
            ["firingRandomness"] = 2,
            ["layerTargetLimits"] = {
                [1] = "Air",
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
                        [1] = "Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0104",
            ["rangeMax"] = 40,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "eb2e236a2589515c5fb9af3a772f0c85ed83316677388e97f80df81164b309ce",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/SAAOlarisAAArtillery02/SAAOlarisAAArtillery02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
