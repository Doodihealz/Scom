-- usl1001: Thaam
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -0.11055593490600585,
                [2] = 0.38169658687214325,
                [3] = 0.019071263137875223,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0201",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 78215,
                ["entry"] = "units/XSL0201/XSL0201_lod0.scm",
                ["sha256"] = "295e34408039fa6cb61e75618ee5faa9d3f4b55b0454bad517250254074ae193",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/usl1001/LOD0/usl1001_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.17187190055847168,
                        ["y"] = -0.00044284101884331344,
                        ["z"] = 0.15872408454929,
                    },
                    ["width"] = 0.266155,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.22790254652500153,
                        ["y"] = 5.329424389646786e-09,
                        ["z"] = 0.046581447124480896,
                    },
                    ["width"] = 0.195993,
                },
            },
            ["unit"] = "usl1001",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0.1,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.8,
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
            ["y"] = 0.25,
            ["z"] = 0.1,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.5,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 280,
            ["regen"] = 0,
            ["value"] = 280,
        },
    },
    ["economy"] = {
        ["buildTime"] = 270,
        ["cost"] = {
            ["alloys"] = 54,
            ["energy"] = 270,
        },
    },
    ["footprint"] = {
        ["x"] = 0.7,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Thaam",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Thaam",
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
            ["Land"] = 67,
            ["WaterSurface"] = 76.7,
        },
        ["tpId"] = "usl1001",
        ["unitTypeName"] = "UnknownT1Tank",
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
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 3.6,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 3.5,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
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
        [1] = "ANTI_SURFACE",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "DIRECT_FIRE",
        [6] = "MOBILE",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER1FACTORY",
        [9] = "SCFA_BUILTBYTIER2FACTORY",
        [10] = "SCFA_BUILTBYTIER3FACTORY",
        [11] = "SCFA_DIRECTFIRE",
        [12] = "SCFA_LAND",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_OVERLAYDIRECTFIRE",
        [15] = "SCFA_PRODUCTFA",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SERAPHIM",
        [19] = "SCFA_TANK",
        [20] = "SCFA_TECH1",
        [21] = "SCFA_VISIBLETORECON",
        [22] = "SERAPHIM",
        [23] = "TANK",
        [24] = "TECH1",
        [25] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl1001/LOD0/usl1001.sananimation",
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
                    ["x"] = 0.126,
                    ["y"] = 0.375,
                    ["z"] = -0.08000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.262,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.39,
                    ["z"] = 0.24400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.08000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.45,
                    ["z"] = 0.262,
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
                ["y"] = 0.25,
                ["z"] = 0.1,
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
                    ["aimBone"] = "Turret_Barrel_Muzzle",
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
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 100,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 100,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom2110",
                },
            },
            ["damage"] = 32,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl1001/muzzle_maingun.sanvfx",
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
                        [1] = "Turret_Barrel_Muzzle",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Barrel_Muzzle"] = {
                    ["aimController"] = "Turret_Barrel_Muzzle",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0129",
            ["rangeMax"] = 18,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1.33333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "70b19395fa61c22d82efdd55c5bc9817c41feafe6b808207db830f3f2ffca598",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/SDFOhCannon01/SDFOhCannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
