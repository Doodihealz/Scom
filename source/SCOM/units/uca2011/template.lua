-- uca2011: Specter
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca2011/LOD0/uca2011_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "e58acbaa3b7797a510ead6a9f4e8610444d7f1a15fcd085b8532ef19c32372cc",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 32,
                },
            },
            ["movementCompatibility"] = "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAA0203/UAA0203_unit.bp",
            ["sourceBlueprintSha256"] = "d6d81b195040dd1ee1fb0f63e683895bb13b3c155717d05e09bc27e4521e4c01",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "BUILTBYTIER2FACTORY",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "GROUNDATTACK",
                [6] = "MOBILE",
                [7] = "OVERLAYDIRECTFIRE",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "TECH2",
                [12] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 10,
            ["sourceId"] = "UAA0203",
            ["sourceKLift"] = 3,
            ["sourceKLiftDamping"] = 2.5,
            ["sourceLiftFactor"] = 7,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca2011",
            ["weapons"] = {
                [1] = {
                    ["label"] = "Turret",
                    ["muzzleSalvoSize"] = 4,
                    ["projectilesPerOnFire"] = 4,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle01",
                                [2] = "Turret_Muzzle02",
                                [3] = "Turret_Muzzle03",
                                [4] = "Turret_Muzzle04",
                            },
                            ["rackBone"] = "C_Barrel",
                        },
                    },
                    ["rateOfFire"] = 1.25,
                    ["reloadTime"] = 0.8,
                    ["sourceCategory"] = "Direct Fire",
                    ["sourceProjectile"] = "/projectiles/ADFLaserLight01/ADFLaserLight01_proj.bp",
                },
                [2] = {
                    ["label"] = "DeathImpact",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {},
                    ["rateOfFire"] = 0,
                    ["reloadTime"] = 0,
                    ["sourceCategory"] = "Death",
                    ["sourceProjectile"] = "",
                },
            },
        },
        ["scoCargo"] = {
            ["airPortable"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["portable"] = false,
            ["slots"] = {},
            ["unfoldDuration"] = 0,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 0.75,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1530",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod5110",
        },
        ["onImpact"] = {
            ["looping"] = false,
            ["name"] = "acod5210",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.175,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 0.5,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1060,
            ["regen"] = 0,
            ["value"] = 1060,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1600,
        ["cost"] = {
            ["alloys"] = 240,
            ["energy"] = 4800,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAirUnit",
        },
        ["displayName"] = "Specter",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Specter",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uca2011",
        ["unitTypeName"] = "Specter",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 12,
        ["air"] = true,
        ["airHover"] = true,
        ["altitudeJitterFactor"] = 1,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["landWhenIdleSeconds"] = 5,
        ["maxBankDegrees"] = 0,
        ["minSpeed"] = 3,
        ["orbitRange"] = 7.639437268410976,
        ["orbitSpeed"] = 12,
        ["patternBySituation"] = {
            ["assist"] = "orbit",
            ["attack"] = "orbit",
            ["hold"] = "idle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["cruise"] = {
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                },
            },
            ["idle"] = {
                ["mode"] = "Orbit",
                ["orbit"] = {
                    ["acceleration"] = 2.167,
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["facing"] = "hold",
                    ["maxSpeed"] = 1.3,
                    ["radius"] = {
                        ["x"] = 0,
                        ["y"] = 0.15,
                    },
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                    ["syncToLateralPhase"] = true,
                },
            },
            ["orbit"] = {
                ["mode"] = "Orbit",
                ["orbit"] = {
                    ["acceleration"] = 2.167,
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["facing"] = "center",
                    ["maxSpeed"] = 1.3,
                    ["radius"] = {
                        ["x"] = 15,
                        ["y"] = 20,
                    },
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                    ["syncToLateralPhase"] = true,
                },
            },
        },
        ["preferredAltitude"] = 10,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 12,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Gunship",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 22,
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
        [1] = "AIR",
        [2] = "ANTI_SURFACE",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CHOSEN",
        [6] = "GUNSHIP",
        [7] = "MOBILE",
        [8] = "TECH2",
        [9] = "SCFA_AEON",
        [10] = "SCFA_AIR",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_GROUNDATTACK",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_OVERLAYDIRECTFIRE",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_TECH2",
        [21] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca2011/LOD0/uca2011.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd3101_death_air_small.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
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
                    ["x"] = 0.18,
                    ["y"] = 0.3,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.265,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.315,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.385,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.375,
                    ["z"] = 0.18,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 105,
            ["lod1distance"] = 275,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 0.75,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = -20,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "C_Barrel",
                    ["pitchMax"] = 40,
                    ["pitchMin"] = -80,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 40,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "C_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 13,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca2011/muzzle_turret.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
                [2] = "Land",
                [3] = "WaterSurface",
                [4] = "Water",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {[1] = "Turret_Muzzle01"},
                },
                [2] = {
                    ["muzzles"] = {[1] = "Turret_Muzzle02"},
                },
                [3] = {
                    ["muzzles"] = {[1] = "Turret_Muzzle03"},
                },
                [4] = {
                    ["muzzles"] = {[1] = "Turret_Muzzle04"},
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 4,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
                ["Turret_Muzzle02"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
                ["Turret_Muzzle03"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
                ["Turret_Muzzle04"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
            },
            ["projectileLifetime"] = 0.6325,
            ["projectileTemplate"] = "psf0059",
            ["rangeMax"] = 22,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.8,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "c093e70058a5a1187918ca5cf8fbd8bc9b4c120657d86d1c08330959a46ba2da",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Turret",
                ["sourceProjectile"] = "/projectiles/ADFLaserLight01/ADFLaserLight01_proj.bp",
            },
            ["scoSourceCategory"] = "Direct Fire",
            ["scoSourceLabel"] = "Turret",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Turret",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 100,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
