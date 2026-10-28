-- uel1001: MA12 Striker
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprintSha256"] = "44881e717eda5d84432dcfc492e9d8c8de6c90b44327d14c8d3afae4c6325376",
            ["sourceId"] = "UEL0201",
            ["sourceScriptSha256"] = "10b1943b06d73f9d4eefb7ced9c1d4835e6c4acbd090532bb5ba11215db5ee24",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 2.8225383061901935e-08,
                [2] = 0.37047398854621666,
                [3] = -0.12447035442008524,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0201",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 41574,
                ["entry"] = "units/UEL0201/UEL0201_LOD0.scm",
                ["sha256"] = "c6fe10ae102f765522a82633d3699ca6911d1a65e7ea28d72a9cbb157cd46a42",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel1001/LOD0/uel1001_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.18344355002045631,
                        ["y"] = 0.00025705502468127423,
                        ["z"] = 0.20423822100597544,
                    },
                    ["width"] = 0.124234,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.18006126582622528,
                        ["y"] = 0.00043400382423907795,
                        ["z"] = -0.08674287430808358,
                    },
                    ["width"] = 0.130606,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.18006126582622528,
                        ["y"] = 0.00043400382423907795,
                        ["z"] = -0.08674287430808358,
                    },
                    ["width"] = 0.130606,
                },
                [4] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.18344355002045631,
                        ["y"] = 0.00025705502468127423,
                        ["z"] = 0.20423822100597544,
                    },
                    ["width"] = 0.124234,
                },
            },
            ["unit"] = "uel1001",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.9,
                ["y"] = 1.2,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1110",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.5,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 300,
            ["regen"] = 0,
            ["value"] = 300,
        },
    },
    ["economy"] = {
        ["buildTime"] = 280,
        ["cost"] = {
            ["alloys"] = 56,
            ["energy"] = 266,
        },
    },
    ["footprint"] = {
        ["x"] = 0.7,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDALandUnit",
        },
        ["displayName"] = "MA12 Striker",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "MA12 Striker",
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
            ["Land"] = 72.9,
            ["WaterSurface"] = 72.9,
        },
        ["tpId"] = "uel1001",
        ["unitTypeName"] = "EDAT1Tank",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 3.4,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 3.4,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 3.4,
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
        [6] = "EDA",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TANK",
        [10] = "TECH1",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER1FACTORY",
        [13] = "SCFA_BUILTBYTIER2FACTORY",
        [14] = "SCFA_BUILTBYTIER3FACTORY",
        [15] = "SCFA_DIRECTFIRE",
        [16] = "SCFA_LAND",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_OVERLAYDIRECTFIRE",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_TANK",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_UEF",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/Death/ved1101_death_land_small.sanvfx",
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
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.39,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.45,
                    ["z"] = 0.162,
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
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.9,
                ["y"] = 1.2,
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
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 10,
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
                    ["name"] = "aeom1110",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 24,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uel1001/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
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
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0151",
            ["rangeMax"] = 18,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "7b4cf765e643ae78c849338be82943eaba000aa10d03565dcd717182aed63460",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/TDFGauss01/TDFGauss01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetCheckInterval"] = 0.5,
            ["targetWaterLimits"] = "Above",
        },
    },
}
