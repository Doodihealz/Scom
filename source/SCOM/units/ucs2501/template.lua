-- ucs2501: Vesper
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["sonarRadius"] = 60,
                    ["waterVisionRadius"] = 45,
                },
                ["runtimeSupported"] = {
                    ["visionRadius"] = 32,
                },
            },
            ["movementCompatibility"] = "Sanctuary routes UnderWater but has no FA SurfacingSub transition state machine; the functional WaterSurface fallback retains source speed/acceleration/turn while submerge depth stays provenance.",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 2,
                    ["z"] = 3,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/XAS0204/XAS0204_unit.bp",
            ["sourceBlueprintSha256"] = "d0576bfabb7db5e9ba4a1b239cac026a3e97070c52129ceb5e1bbd3c769667a0",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ANTINAVY",
                [3] = "BUILTBYEXPERIMENTALSUB",
                [4] = "BUILTBYTIER2FACTORY",
                [5] = "BUILTBYTIER3FACTORY",
                [6] = "MOBILE",
                [7] = "NAVAL",
                [8] = "OVERLAYANTINAVY",
                [9] = "OVERLAYDEFENSE",
                [10] = "OVERLAYSONAR",
                [11] = "PRODUCTFA",
                [12] = "RECLAIMABLE",
                [13] = "SELECTABLE",
                [14] = "SUBMERSIBLE",
                [15] = "T2SUBMARINE",
                [16] = "TECH2",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = -1.5,
            ["sourceId"] = "XAS0204",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 6.5,
            ["sourceMotionType"] = "RULEUMT_SurfacingSub",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2501",
            ["weapons"] = {
                [1] = {
                    ["label"] = "Torpedo01",
                    ["muzzleSalvoSize"] = 4,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Projectile_Front_Right",
                                [2] = "Projectile_Front_Left",
                            },
                            ["rackBone"] = "Projectile_Front_Right",
                        },
                    },
                    ["rateOfFire"] = 0.25,
                    ["reloadTime"] = 4,
                    ["sourceCategory"] = "Anti Navy",
                    ["sourceProjectile"] = "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp",
                },
                [2] = {
                    ["label"] = "AntiTorpedo01",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Projectile_Right_Center01",
                                [2] = "Projectile_Left_Center01",
                            },
                            ["rackBone"] = "Projectile_Right_Center01",
                        },
                    },
                    ["rateOfFire"] = 0.13,
                    ["reloadTime"] = 7.692307692307692,
                    ["sourceCategory"] = "Defense",
                    ["sourceProjectile"] = "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp",
                },
            },
        },
        ["scoSourceInterception"] = {
            ["sourceId"] = "XAS0204",
            ["weapons"] = {
                ["AntiTorpedo01"] = {
                    ["counted"] = false,
                    ["damage"] = 2,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 80,
                    ["muzzles"] = {
                        [1] = "Projectile_Right_Center01",
                        [2] = "Projectile_Left_Center01",
                    },
                    ["projectile"] = "psf0177",
                    ["rangeMax"] = 32,
                    ["rangeMin"] = 0,
                    ["reload"] = 7.692307692307692,
                    ["sourceIndex"] = 2,
                    ["sourceLabel"] = "AntiTorpedo01",
                    ["targetClass"] = "torpedo",
                },
            },
        },
        ["seaParityUnsupported"] = {
            ["projectileInterception"] = true,
        },
        ["seaParityWeaponSemantics"] = {
            ["Torpedo01"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0.05,
                ["y"] = 0.04999999999999999,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 1.8,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod3110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0.05,
            ["y"] = 0.04999999999999999,
            ["z"] = -0.01,
        },
        ["collisionSize"] = {
            ["x"] = 0.65,
            ["y"] = 0.5,
            ["z"] = 2.8,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1800,
            ["regen"] = 0,
            ["value"] = 1800,
        },
    },
    ["economy"] = {
        ["buildTime"] = 4400,
        ["cost"] = {
            ["alloys"] = 1100,
            ["energy"] = 8800,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortNavalUnit",
        },
        ["displayName"] = "Vesper",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Vesper",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucs2501",
        ["unitTypeName"] = "Vesper",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 6.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 6.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 80,
        ["sortOrder"] = 1,
        ["speed"] = 6.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 45,
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
        [1] = "ANTI_NAVAL",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CHOSEN",
        [5] = "MOBILE",
        [6] = "NAVAL",
        [7] = "TECH2",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ANTINAVY",
        [11] = "SCFA_BUILTBYEXPERIMENTALSUB",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_NAVAL",
        [16] = "SCFA_OVERLAYANTINAVY",
        [17] = "SCFA_OVERLAYDEFENSE",
        [18] = "SCFA_OVERLAYSONAR",
        [19] = "SCFA_PRODUCTFA",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SUBMERSIBLE",
        [23] = "SCFA_T2SUBMARINE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucs2501/LOD0/ucs2501.sananimation",
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
                    ["audioName"] = "chosen_unit_death_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16699999999999998,
                    ["y"] = 0.175,
                    ["z"] = -0.57,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.09300000000000001,
                    ["y"] = 0.13999999999999999,
                    ["z"] = 0.494,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.19,
                    ["z"] = 0.43799999999999994,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16699999999999998,
                    ["y"] = 0.26,
                    ["z"] = -0.57,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.09300000000000001,
                    ["y"] = 0.25,
                    ["z"] = 0.494,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 73,
            ["lod1distance"] = 190,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0.05,
                ["y"] = 0.04999999999999999,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 1.8,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Projectile_Front_Right",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Projectile_Front_Right",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Projectile_Front_Right",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 90,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs2501/muzzle_torpedo01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Front_Right",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Front_Left",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Front_Right",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Front_Left",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.4,
            ["muzzleSalvoSize"] = 4,
            ["muzzles"] = {
                ["Projectile_Front_Left"] = {
                    ["aimController"] = "Projectile_Front_Right",
                },
                ["Projectile_Front_Right"] = {
                    ["aimController"] = "Projectile_Front_Right",
                },
            },
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0053",
            ["rangeMax"] = 45,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Torpedo01",
                ["sourceProjectile"] = "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Navy",
            ["scoSourceLabel"] = "Torpedo01",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Torpedo01",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Projectile_Right_Center01",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Projectile_Right_Center01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["projectileSpeed"] = 80,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Projectile_Right_Center01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 2,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs2501/muzzle_antitorpedo01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Right_Center01",
                        [2] = "Projectile_Left_Center01",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Projectile_Left_Center01"] = {
                    ["aimController"] = "Projectile_Right_Center01",
                },
                ["Projectile_Right_Center01"] = {
                    ["aimController"] = "Projectile_Right_Center01",
                },
            },
            ["name"] = "AntiTorpedo01",
            ["projectileLifetime"] = 4,
            ["projectileTemplate"] = "psf0177",
            ["rangeMax"] = 32,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 7.692307692307692,
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "d0576bfabb7db5e9ba4a1b239cac026a3e97070c52129ceb5e1bbd3c769667a0",
                ["sourceId"] = "XAS0204",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AntiTorpedo01",
            },
            ["scoFaSourceWeapon"] = {
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "XAS_Weapon",
                        ["Cue"] = "XAS0204_AntiTorpedo",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["CollideFriendly"] = false,
                ["Damage"] = 2,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Quasar Anti-Torpedo",
                ["FireTargetLayerCapsTable"] = {
                    ["Sub"] = "Seabed|Sub|Water",
                    ["Water"] = "Seabed|Sub|Water",
                },
                ["FiringTolerance"] = 2,
                ["Label"] = "AntiTorpedo01",
                ["LeadTarget"] = false,
                ["MaxRadius"] = 32,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["MuzzleVelocity"] = 80,
                ["ProjectileId"] = "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp",
                ["ProjectileLifetime"] = 4,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Projectile_Right_Center01",
                            [2] = "Projectile_Left_Center01",
                        },
                        ["RackBone"] = "Projectile_Right_Center01",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 0,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RangeCategory"] = "UWRC_Countermeasure",
                ["RateOfFire"] = 0.13,
                ["TargetCheckInterval"] = 0.5,
                ["TargetRestrictDisallow"] = "UNTARGETABLE",
                ["TargetRestrictOnlyAllow"] = "TORPEDO",
                ["TargetType"] = "RULEWTT_Projectile",
                ["TrackingRadius"] = 1.15,
                ["TurretDualManipulators"] = false,
                ["TurretPitch"] = 0,
                ["TurretPitchRange"] = 0,
                ["TurretPitchSpeed"] = 0,
                ["TurretYaw"] = 0,
                ["TurretYawRange"] = 0,
                ["TurretYawSpeed"] = 0,
                ["Turreted"] = false,
                ["WeaponCategory"] = "Defense",
                ["WeaponRepackTimeout"] = 0,
                ["WeaponUnpacks"] = false,
            },
            ["scoFaSourceWeaponIndex"] = 2,
            ["scoSourceInterceptionLabel"] = "AntiTorpedo01",
            ["scoTacticalOwned"] = true,
        },
    },
}
