-- ucl2101: Evensong
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
                    ["x"] = 0.75,
                    ["z"] = 1.1,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0111/UAL0111_unit.bp",
            ["sourceBlueprintSha256"] = "458841c9b1ba7edfcb221afdb71b6eb02be6d8bedbd9a34290abc492d2be944b",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2FACTORY",
                [3] = "BUILTBYTIER3FACTORY",
                [4] = "INDIRECTFIRE",
                [5] = "LAND",
                [6] = "MOBILE",
                [7] = "OVERLAYINDIRECTFIRE",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "SILO",
                [12] = "TECH2",
                [13] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAL0111",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 2.7,
            ["sourceMotionType"] = "RULEUMT_Land",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl2101",
            ["weapons"] = {
                [1] = {
                    ["label"] = "MissileRack",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Missile",
                            },
                            ["rackBone"] = "Missile",
                        },
                    },
                    ["rateOfFire"] = 0.1,
                    ["reloadTime"] = 10,
                    ["sourceCategory"] = "Missile",
                    ["sourceProjectile"] = "/projectiles/AIFMissileSerpentine01/AIFMissileSerpentine01_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -7.934705159584609e-09,
                [2] = 0.5010207790865597,
                [3] = 0.1869507127294888,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0111",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 80166,
                ["entry"] = "units/UAL0111/UAL0111_LOD0.scm",
                ["sha256"] = "122a9f9697df35d6790f869ffcacf2ad76c76b5e663f0944a3630db25efc6fb3",
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15,
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
            ["y"] = 0.15,
            ["z"] = 0.1,
        },
        ["collisionSize"] = {
            ["x"] = 0.75,
            ["y"] = 0.3,
            ["z"] = 1.1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 750,
            ["regen"] = 0,
            ["value"] = 750,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1000,
        ["cost"] = {
            ["alloys"] = 200,
            ["energy"] = 1500,
        },
    },
    ["footprint"] = {
        ["x"] = 0.75,
        ["y"] = 1.1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Evensong",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Evensong",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["StrategicManualLaunch"] = true,
        },
        ["tpId"] = "ucl2101",
        ["unitTypeName"] = "Evensong",
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
            ["innerRadius"] = 3,
            ["outerRadius"] = 60,
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
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "INDIRECT_FIRE",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "TECH2",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2FACTORY",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_INDIRECTFIRE",
        [13] = "SCFA_LAND",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYINDIRECTFIRE",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SILO",
        [20] = "SCFA_TECH2",
        [21] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl2101/LOD0/ucl2101.sananimation",
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
                    ["x"] = 0.135,
                    ["y"] = 0.22499999999999998,
                    ["z"] = -0.12000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.204,
                    ["z"] = 0.29800000000000004,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.15000000000000002,
                    ["y"] = 0.23399999999999999,
                    ["z"] = 0.276,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 0.276,
                    ["z"] = -0.12000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.27,
                    ["z"] = 0.29800000000000004,
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
                ["y"] = 0.15,
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
                    ["aimBone"] = "Missile",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Missile",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 3,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Missile",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 600,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl2101/muzzle_missilerack.sanvfx",
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
                        [1] = "Missile",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Missile"] = {
                    ["aimController"] = "Missile",
                },
            },
            ["projectileLifetime"] = 25,
            ["projectileTemplate"] = "psf0073",
            ["rangeMax"] = 60,
            ["rangeMin"] = 3,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 10,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "1376c174654070b29fdc47935b7f7b921acf5a2045e05ec78aaee49d0976e86f",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack",
                ["sourceProjectile"] = "/projectiles/AIFMissileSerpentine01/AIFMissileSerpentine01_proj.bp",
            },
            ["scoSourceCategory"] = "Missile",
            ["scoSourceLabel"] = "MissileRack",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
