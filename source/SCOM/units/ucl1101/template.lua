-- ucl1101: Fervor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 18,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.55,
                    ["z"] = 0.6,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0103/UAL0103_unit.bp",
            ["sourceBlueprintSha256"] = "12fcb0c622a8509568b0e5066b59dd41181c7b8ac2f4a180bf9f66168a84619e",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ARTILLERY",
                [3] = "BUILTBYTIER1FACTORY",
                [4] = "BUILTBYTIER2FACTORY",
                [5] = "BUILTBYTIER3FACTORY",
                [6] = "INDIRECTFIRE",
                [7] = "LAND",
                [8] = "MOBILE",
                [9] = "OVERLAYINDIRECTFIRE",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "TECH1",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAL0103",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 2.7,
            ["sourceMotionType"] = "RULEUMT_Land",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl1101",
            ["weapons"] = {
                [1] = {
                    ["label"] = "MainGun",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle",
                            },
                            ["rackBone"] = "Turret_Barrel",
                        },
                    },
                    ["rateOfFire"] = 0.5,
                    ["reloadTime"] = 2,
                    ["sourceCategory"] = "Artillery",
                    ["sourceProjectile"] = "/projectiles/AIFMortar01/AIFMortar01_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 3.231107257306576e-09,
                [2] = 0.2814024447100183,
                [3] = -0.027516363403672705,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0103",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 71525,
                ["entry"] = "units/UAL0103/UAL0103_LOD0.scm",
                ["sha256"] = "115f4252df6b8d8dd312f082237021d49a67fe261971b982768d92b84584f8b2",
            },
        },
        ["scoGameplayT1ArtilleryArc"] = true,
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ucl1101/LOD0/ucl1101_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.12553717195987701,
                        ["y"] = -0.00017264008856974176,
                        ["z"] = 0.024065956502455813,
                    },
                    ["width"] = 0.105018,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.12553717195987701,
                        ["y"] = -0.00017264008856974176,
                        ["z"] = 0.024065956502455813,
                    },
                    ["width"] = 0.105018,
                },
            },
            ["unit"] = "ucl1101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.125,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.45,
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
            ["y"] = 0.125,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.55,
            ["y"] = 0.25,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 150,
            ["regen"] = 0,
            ["value"] = 150,
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
        ["x"] = 0.55,
        ["y"] = 0.6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Fervor",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Fervor",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucl1101",
        ["unitTypeName"] = "Fervor",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 2.7,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.7,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 2.7,
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
        [5] = "CHOSEN",
        [6] = "INDIRECT_FIRE",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH1",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_ARTILLERY",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_INDIRECTFIRE",
        [17] = "SCFA_LAND",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_OVERLAYINDIRECTFIRE",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_TECH1",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl1101/LOD0/ucl1101.sananimation",
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
                    ["x"] = 0.099,
                    ["y"] = 0.1875,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.12100000000000001,
                    ["y"] = 0.16999999999999998,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11000000000000001,
                    ["y"] = 0.195,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.099,
                    ["y"] = 0.22999999999999998,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.12100000000000001,
                    ["y"] = 0.225,
                    ["z"] = 0.108,
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
                ["y"] = 0.125,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.45,
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
                    ["aimTolerance"] = 3,
                    ["defaultPitchAdjustment"] = 45,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 135,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 70,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 14,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 45,
                    ["yawMin"] = -45,
                    ["yawSpeed"] = 70,
                },
            },
            ["damage"] = 200,
            ["damageRadius"] = 0.5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl1101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Water",
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
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 20,
            ["projectileTemplate"] = "psf0076",
            ["rangeMax"] = 30,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "5553a1a332848e3efdaae41971c8c4d86995424a5e224f2542746a1029af359a",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/AIFMortar01/AIFMortar01_proj.bp",
            },
            ["scoSourceCategory"] = "Artillery",
            ["scoSourceLabel"] = "MainGun",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
