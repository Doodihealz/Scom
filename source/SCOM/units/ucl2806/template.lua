-- ucl2806: Blaze
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
                    ["visionRadius"] = 15,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.9,
                    ["z"] = 1.2,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XAL0203/XAL0203_unit.bp",
            ["sourceBlueprintSha256"] = "bfe8fa65517b2c7959535fa79bfff36a9c14c6dda1a56bc20c607a2e550ef59d",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2FACTORY",
                [3] = "BUILTBYTIER3FACTORY",
                [4] = "DIRECTFIRE",
                [5] = "HOVER",
                [6] = "LAND",
                [7] = "MOBILE",
                [8] = "OVERLAYDIRECTFIRE",
                [9] = "PRODUCTFA",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "TANK",
                [13] = "TECH2",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0.15,
            ["sourceId"] = "XAL0203",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 3.7,
            ["sourceMotionType"] = "RULEUMT_Hover",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl2806",
            ["weapons"] = {
                [1] = {
                    ["label"] = "MainGun",
                    ["muzzleSalvoSize"] = 0,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Gun_Muzzle01",
                            },
                            ["rackBone"] = "Gun_Barrel",
                        },
                        [2] = {
                            ["muzzles"] = {
                                [1] = "Gun_Muzzle02",
                            },
                            ["rackBone"] = "Gun_Barrel",
                        },
                    },
                    ["rateOfFire"] = 3,
                    ["reloadTime"] = 0.3333333333333333,
                    ["sourceCategory"] = "Direct Fire",
                    ["sourceProjectile"] = "/projectiles/ADFQuatumAutoGun01/ADFQuatumAutoGun01_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 8.250781036167608e-10,
                [2] = 0.4287682412543427,
                [3] = -0.05873210206409799,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XAL0203",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 53283,
                ["entry"] = "units/XAL0203/XAL0203_lod0.scm",
                ["sha256"] = "c426064df1aa39bd8adc2a7445a7f4e958cc304456353d332f69dfb7ae90fb5a",
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixHoverStrafe"] = {
            ["faceTurnRateMultiplier"] = 1.3333333333333333,
            ["nativeFacingMarkerMask"] = 1073741824,
            ["orbitRange"] = 16.099999999999998,
            ["orbitSpeed"] = 3.7,
            ["preserveWeaponAimWhileMoving"] = true,
            ["runtimeGroundHoverOrderConsumerRequired"] = true,
            ["runtimeNativeStrafeChassisPatchRequired"] = true,
            ["targetBodyFacingWhileOrbiting"] = true,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.95,
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
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 0.5,
            ["z"] = 1.2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1050,
            ["regen"] = 0,
            ["value"] = 1050,
        },
    },
    ["economy"] = {
        ["buildTime"] = 880,
        ["cost"] = {
            ["alloys"] = 220,
            ["energy"] = 1320,
        },
    },
    ["footprint"] = {
        ["x"] = 0.9,
        ["y"] = 1.2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Blaze",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Blaze",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucl2806",
        ["unitTypeName"] = "Blaze",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["movement"] = {
        ["acceleration"] = 3.7,
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
        ["deceleration"] = 3.7,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 16.099999999999998,
        ["orbitSpeed"] = 3.7,
        ["patternBySituation"] = {
            ["attack"] = "scomHoverOrbit",
        },
        ["patterns"] = {
            ["scomHoverOrbit"] = {
                ["circle"] = {
                    ["radius"] = 16.099999999999998,
                    ["speed"] = 3.7,
                },
                ["mode"] = "Circle",
                ["orbit"] = {
                    ["facing"] = "center",
                    ["maxSpeed"] = 3.7,
                },
            },
        },
        ["preferredAltitude"] = 0.15,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 3.7,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 23,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "DIRECT_FIRE",
        [5] = "HOVER",
        [6] = "LAND",
        [7] = "MOBILE",
        [8] = "TANK",
        [9] = "TECH2",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_DIRECTFIRE",
        [15] = "SCFA_HOVER",
        [16] = "SCFA_LAND",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_OVERLAYDIRECTFIRE",
        [19] = "SCFA_PRODUCTFA",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_TANK",
        [23] = "SCFA_TECH2",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl2806/LOD0/ucl2806.sananimation",
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
                    ["x"] = 0.162,
                    ["y"] = 0.375,
                    ["z"] = -0.24,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.216,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.39,
                    ["z"] = 0.192,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.24,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.45,
                    ["z"] = 0.216,
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
                ["x"] = 0.6,
                ["y"] = 0.95,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Gun_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Gun_Barrel",
                    ["pitchMax"] = 30,
                    ["pitchMin"] = -30,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Root",
                    ["yawMax"] = 10,
                    ["yawMin"] = -10,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 15,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl2806/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Water",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Gun_Muzzle01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Gun_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Gun_Muzzle01"] = {
                    ["aimController"] = "Gun_Muzzle01",
                },
                ["Gun_Muzzle02"] = {
                    ["aimController"] = "Gun_Muzzle01",
                },
            },
            ["projectileLifetime"] = 0.8816666666666667,
            ["projectileTemplate"] = "psf0068",
            ["rangeMax"] = 23,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.3333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "54c4c74bab138672841cd431824b60dfaa8437cfac713342a55522aa3f4787ff",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/ADFQuatumAutoGun01/ADFQuatumAutoGun01_proj.bp",
            },
            ["scoSourceCategory"] = "Direct Fire",
            ["scoSourceLabel"] = "MainGun",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
