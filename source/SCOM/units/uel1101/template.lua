-- uel1101: Lobo
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["fragmentationChildCount"] = 5,
            ["fragmentationSensorVisionSupported"] = false,
            ["sourceBlueprintSha256"] = "7c4904970ce52c5abce8222a6627ea0e59bf309a6da9dc3faec8722c3fcf3945",
            ["sourceId"] = "UEL0103",
            ["sourceScriptSha256"] = "7aeef99857e4a2d702cbe896487f29503dd02c3dac1fb49db75f11832bc47c64",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 4.5462227094006384e-10,
                [2] = 0.39113654996261016,
                [3] = -0.1358413912047727,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0103",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 47786,
                ["entry"] = "units/UEL0103/UEL0103_LOD0.scm",
                ["sha256"] = "e012bc1b3012a3cb08b73d012b1a7ba9c5da6d774c51c356f31677957f4535ae",
            },
        },
        ["scoGameplayT1ArtilleryArc"] = true,
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel1101/LOD0/uel1101_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.13888902589678764,
                        ["y"] = -0.002444688178151423,
                        ["z"] = 0.26127859246222285,
                    },
                    ["width"] = 0.0652,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.13888901472091675,
                        ["y"] = -0.0024447430573486728,
                        ["z"] = -0.1581577282002723,
                    },
                    ["width"] = 0.0652,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.13888901099562645,
                        ["y"] = -0.0024447650214700486,
                        ["z"] = -0.31330023664744105,
                    },
                    ["width"] = 0.0652,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.13871293514966965,
                        ["y"] = -0.0024447650214675363,
                        ["z"] = -0.31330022174627986,
                    },
                    ["width"] = 0.0652,
                },
                [5] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.13871293887495995,
                        ["y"] = -0.0024447430573486728,
                        ["z"] = -0.1581577282002723,
                    },
                    ["width"] = 0.0652,
                },
                [6] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.13871295005083084,
                        ["y"] = -0.0024446881781451427,
                        ["z"] = 0.26127862971512583,
                    },
                    ["width"] = 0.0652,
                },
            },
            ["unit"] = "uel1101",
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
            ["x"] = 0.45,
            ["y"] = 0.4,
            ["z"] = 0.8,
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
        ["buildTime"] = 180,
        ["cost"] = {
            ["alloys"] = 36,
            ["energy"] = 180,
        },
    },
    ["footprint"] = {
        ["x"] = 0.45,
        ["y"] = 0.8,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDALandUnit",
        },
        ["displayName"] = "Lobo",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "indirect",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Lobo",
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
            ["Land"] = 31.9,
            ["WaterSurface"] = 45.5,
        },
        ["tpId"] = "uel1101",
        ["unitTypeName"] = "EDAT1MobileArty",
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
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 3,
        ["speed"] = 2.8,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 5,
            ["outerRadius"] = 30,
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
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "EDA",
        [6] = "INDIRECT_FIRE",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH1",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_ARTILLERY",
        [12] = "SCFA_BUILTBYTIER1FACTORY",
        [13] = "SCFA_BUILTBYTIER2FACTORY",
        [14] = "SCFA_BUILTBYTIER3FACTORY",
        [15] = "SCFA_INDIRECTFIRE",
        [16] = "SCFA_INTELLIGENCE",
        [17] = "SCFA_LAND",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_OVERLAYINDIRECTFIRE",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_UEF",
        [25] = "SCFA_VISIBLETORECON",
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
                    ["audioName"] = "eda_unit_death_small",
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
                    ["x"] = 0.081,
                    ["y"] = 0.30000000000000004,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.099,
                    ["y"] = 0.272,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09000000000000001,
                    ["y"] = 0.31200000000000006,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.081,
                    ["y"] = 0.368,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.099,
                    ["y"] = 0.36000000000000004,
                    ["z"] = 0.144,
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
                    ["aimBone"] = "Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 45,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 70,
                    ["poseResetTime"] = 10,
                    ["projectileSpeed"] = 14,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 70,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom3210",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 120,
            ["damageFriendly"] = false,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uel1101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0.5,
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
            ["projectileLifetime"] = 20,
            ["projectileTemplate"] = "psf0160",
            ["rangeMax"] = 30,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 10,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "b6ffd27313b8e94956dbf454fe524028bec8c8e6b406924a0b0cba3228fd4833",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/TIFFragmentationSensorShell01/TIFFragmentationSensorShell01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetCheckInterval"] = 1,
            ["targetWaterLimits"] = "Above",
        },
    },
}
