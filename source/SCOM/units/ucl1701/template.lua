-- ucl1701: Spirit
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
                    ["radarRadius"] = 50,
                    ["visionRadius"] = 24,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.5,
                    ["z"] = 0.6,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0101/UAL0101_unit.bp",
            ["sourceBlueprintSha256"] = "14f3317d890005b6861e5be43fc0a33db1518d14dace2c67431fec37d3840f99",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER1FACTORY",
                [3] = "BUILTBYTIER2FACTORY",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "COUNTERINTELLIGENCE",
                [6] = "DIRECTFIRE",
                [7] = "HOVER",
                [8] = "LAND",
                [9] = "MOBILE",
                [10] = "OVERLAYDIRECTFIRE",
                [11] = "OVERLAYRADAR",
                [12] = "PRODUCTSC1",
                [13] = "RECLAIMABLE",
                [14] = "SCOUT",
                [15] = "SELECTABLE",
                [16] = "TECH1",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0.25,
            ["sourceId"] = "UAL0101",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 5,
            ["sourceMotionType"] = "RULEUMT_Hover",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl1701",
            ["weapons"] = {
                [1] = {
                    ["label"] = "LaserTurret",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle",
                            },
                            ["rackBone"] = "Turret",
                        },
                    },
                    ["rateOfFire"] = 0.5,
                    ["reloadTime"] = 2,
                    ["sourceCategory"] = "Direct Fire",
                    ["sourceProjectile"] = "/projectiles/ADFLaserLight02/ADFLaserLight02_proj.bp",
                },
            },
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.1890418052673341,
                [3] = -6.457488587005788e-10,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0101",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 47430,
                ["entry"] = "units/UAL0101/UAL0101_LOD0.scm",
                ["sha256"] = "557fc2fb622594ac1aa18673d7e10d47678243ab2f1d49ade24f2311f024afef",
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixHoverStrafe"] = {
            ["orbitRange"] = 17.5,
            ["orbitSpeed"] = 5,
            ["preserveWeaponAimWhileMoving"] = true,
            ["runtimeGroundHoverOrderConsumerRequired"] = true,
            ["runtimeNativeStrafeChassisPatchRequired"] = false,
            ["targetBodyFacingWhileOrbiting"] = false,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.04999999999999999,
                ["z"] = 0.05,
            },
            ["size"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
            ["y"] = 0.04999999999999999,
            ["z"] = 0.05,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 0.3,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 20,
            ["regen"] = 0,
            ["value"] = 20,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80,
        ["cost"] = {
            ["alloys"] = 8,
            ["energy"] = 40,
        },
    },
    ["footprint"] = {
        ["x"] = 0.5,
        ["y"] = 0.6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Spirit",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Spirit",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucl1701",
        ["unitTypeName"] = "Spirit",
    },
    ["intel"] = {
        ["radarRadius"] = 50,
        ["visionRadius"] = 24,
    },
    ["movement"] = {
        ["acceleration"] = 5,
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
        ["deceleration"] = 5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 17.5,
        ["orbitSpeed"] = 5,
        ["patternBySituation"] = {
            ["attack"] = "scomHoverOrbit",
        },
        ["patterns"] = {
            ["scomHoverOrbit"] = {
                ["circle"] = {
                    ["radius"] = 17.5,
                    ["speed"] = 5,
                },
                ["mode"] = "Circle",
                ["orbit"] = {
                    ["facing"] = "travel",
                    ["maxSpeed"] = 5,
                },
            },
        },
        ["preferredAltitude"] = 0.25,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 50,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_FACTORY",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CHOSEN",
        [5] = "DIRECT_FIRE",
        [6] = "HOVER",
        [7] = "INTEL",
        [8] = "LAND",
        [9] = "MOBILE",
        [10] = "RADAR",
        [11] = "SCOUT",
        [12] = "TECH1",
        [13] = "SCFA_AEON",
        [14] = "SCFA_ALLUNITS",
        [15] = "SCFA_BUILTBYTIER1FACTORY",
        [16] = "SCFA_BUILTBYTIER2FACTORY",
        [17] = "SCFA_BUILTBYTIER3FACTORY",
        [18] = "SCFA_COUNTERINTELLIGENCE",
        [19] = "SCFA_DIRECTFIRE",
        [20] = "SCFA_HOVER",
        [21] = "SCFA_LAND",
        [22] = "SCFA_MOBILE",
        [23] = "SCFA_OVERLAYDIRECTFIRE",
        [24] = "SCFA_OVERLAYRADAR",
        [25] = "SCFA_PRODUCTSC1",
        [26] = "SCFA_RECLAIMABLE",
        [27] = "SCFA_SCOUT",
        [28] = "SCFA_SELECTABLE",
        [29] = "SCFA_TECH1",
        [30] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl1701/LOD0/ucl1701.sananimation",
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
                    ["x"] = 0.09,
                    ["y"] = 0.12499999999999999,
                    ["z"] = -0.06999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.10399999999999998,
                    ["z"] = 0.158,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.134,
                    ["z"] = 0.14600000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.176,
                    ["z"] = -0.06999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.16999999999999998,
                    ["z"] = 0.158,
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
                ["y"] = 0.04999999999999999,
                ["z"] = 0.05,
            },
            ["size"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
                    ["pitchMax"] = 180,
                    ["pitchMin"] = -180,
                    ["pitchSpeed"] = 85,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 2,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl1701/muzzle_laserturret.sanvfx",
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
            ["projectileLifetime"] = 1.15,
            ["projectileTemplate"] = "psf0060",
            ["rangeMax"] = 25,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "7327def8e74160fb7d6e1030cf54fbfac2930b1c55b9ba8febb69c0267f6482d",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LaserTurret",
                ["sourceProjectile"] = "/projectiles/ADFLaserLight02/ADFLaserLight02_proj.bp",
            },
            ["scoSourceCategory"] = "Direct Fire",
            ["scoSourceLabel"] = "LaserTurret",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LaserTurret",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
