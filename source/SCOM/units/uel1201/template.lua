-- uel1201: Archer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["projectilesPerOnFire"] = 2,
            ["rackSalvoSize"] = 2,
            ["sanctuaryParallelProjectilesPerMuzzle"] = 2,
            ["sourceBlueprintSha256"] = "257f39a9239b57204212b1c7494973342448ced3581b4c5fcbcfad7a8f4bd7be",
            ["sourceId"] = "UEL0104",
            ["sourceMuzzleBones"] = {
                [1] = "Turret_Muzzle_01",
                [2] = "Turret_Muzzle_02",
            },
            ["sourceMuzzleVelocity"] = 45,
            ["sourceProjectileInitialSpeed"] = 120,
            ["sourceScriptSha256"] = "de27103243a0bb4de04b41464d77eca4e8d06bc2ba8e63e316546d7aeecd7c6b",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 4.710802095360123e-06,
                [2] = 0.3807544604830613,
                [3] = -0.05179124899792414,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0104",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 43143,
                ["entry"] = "units/UEL0104/UEL0104_LOD0.scm",
                ["sha256"] = "dce69b038946754e41a1f7a70fe10c4de1c15c605be52207a674799e1294ad1a",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel1201/LOD0/uel1201_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.14449575915932655,
                        ["y"] = -0.00037140616726945394,
                        ["z"] = -0.27121680223641215,
                    },
                    ["width"] = 0.059918,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.14449574053287506,
                        ["y"] = -0.0003717984712141375,
                        ["z"] = 0.2633495182425778,
                    },
                    ["width"] = 0.059918,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.14449574053287506,
                        ["y"] = 0.002456363692280584,
                        ["z"] = 0.2633495103152047,
                    },
                    ["width"] = 0.059918,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.14449575915932655,
                        ["y"] = 0.0024563098927095147,
                        ["z"] = -0.27121682506487127,
                    },
                    ["width"] = 0.059918,
                },
            },
            ["unit"] = "uel1201",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.2,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 1,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1210",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.2,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 0.4,
            ["z"] = 0.7,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 200,
            ["regen"] = 0,
            ["value"] = 200,
        },
    },
    ["economy"] = {
        ["buildTime"] = 140,
        ["cost"] = {
            ["alloys"] = 28,
            ["energy"] = 140,
        },
    },
    ["footprint"] = {
        ["x"] = 0.5,
        ["y"] = 0.7,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDALandUnit",
        },
        ["displayName"] = "Archer",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "aa",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_antiAir.png",
        ["iconUIBuildSortPriority"] = 50,
        ["iconUIType"] = "land",
        ["name"] = "Archer",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 76.9,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uel1201",
        ["unitTypeName"] = "EDAT1MAA",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 2.8,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.8,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 80,
        ["sortOrder"] = 5,
        ["speed"] = 2.8,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
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
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "EDA",
        [6] = "LAND",
        [7] = "MOBILE",
        [8] = "TECH1",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ANTIAIR",
        [11] = "SCFA_BUILTBYTIER1FACTORY",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_LAND",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_OVERLAYANTIAIR",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_TECH1",
        [21] = "SCFA_UEF",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/Death/ved1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.30000000000000004,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.272,
                    ["z"] = 0.126,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.31200000000000006,
                    ["z"] = 0.11199999999999999,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.368,
                    ["z"] = -0.13999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.36000000000000004,
                    ["z"] = 0.126,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 172,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.2,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 1,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 45,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 40,
                    ["pitchMin"] = -40,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 10,
                    ["projectileSpeed"] = 45,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom1111",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 8,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uel1201/muzzle_aagun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_01",
                        [2] = "Turret_Muzzle_01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_02",
                        [2] = "Turret_Muzzle_02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 2,
            ["projectileLifetime"] = 2.5,
            ["projectileTemplate"] = "psf0025",
            ["rangeMax"] = 32,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.4,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/TAARailgun01/TAARailgun01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
            },
            ["targetCheckInterval"] = 0.3,
            ["targetWaterLimits"] = "Above",
        },
    },
}
