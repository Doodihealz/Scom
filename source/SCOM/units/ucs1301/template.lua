-- ucs1301: Tide
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
                    ["sonarRadius"] = 35,
                    ["waterVisionRadius"] = 45,
                },
                ["runtimeSupported"] = {
                    ["visionRadius"] = 12,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = 0,
                    ["offsetZ"] = 0,
                    ["sizeX"] = 1,
                    ["sizeZ"] = 1,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB2109/UAB2109_unit.bp",
            ["sourceBlueprintSha256"] = "49f595281ffbb407e2274945ef9768c95798d9ef6a69c6c6efae4b257cfbc05a",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ANTINAVY",
                [3] = "BUILTBYCOMMANDER",
                [4] = "BUILTBYTIER1ENGINEER",
                [5] = "BUILTBYTIER2ENGINEER",
                [6] = "BUILTBYTIER3ENGINEER",
                [7] = "DEFENSE",
                [8] = "DRAGBUILD",
                [9] = "OVERLAYANTINAVY",
                [10] = "OVERLAYSONAR",
                [11] = "PRODUCTSC1",
                [12] = "RECLAIMABLE",
                [13] = "SELECTABLE",
                [14] = "SIZE4",
                [15] = "SORTDEFENSE",
                [16] = "STRUCTURE",
                [17] = "TECH1",
                [18] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB2109",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs1301",
            ["weapons"] = {
                [1] = {
                    ["label"] = "Turret01",
                    ["muzzleSalvoSize"] = 2,
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
                    ["rateOfFire"] = 0.25,
                    ["reloadTime"] = 4,
                    ["sourceCategory"] = "Anti Navy",
                    ["sourceProjectile"] = "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp",
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = -0.05,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 2,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1625,
            ["regen"] = 0,
            ["value"] = 1625,
        },
    },
    ["economy"] = {
        ["buildTime"] = 450,
        ["cost"] = {
            ["alloys"] = 450,
            ["energy"] = 3600,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Tide",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "water",
        ["name"] = "Tide",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucs1301",
        ["unitTypeName"] = "Tide",
    },
    ["intel"] = {
        ["visionRadius"] = 12,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 50,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 12,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 12,
        },
    },
    ["skirtSize"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "ANTI_NAVAL",
        [2] = "BUILDABLE_BY_T1_ENGINEER",
        [3] = "BUILDABLE_BY_T2_ENGINEER",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "CHOSEN",
        [6] = "DEFENCE",
        [7] = "STRUCTURE",
        [8] = "TECH1",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_ANTINAVY",
        [12] = "SCFA_BUILTBYCOMMANDER",
        [13] = "SCFA_BUILTBYTIER1ENGINEER",
        [14] = "SCFA_BUILTBYTIER2ENGINEER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
        [16] = "SCFA_DEFENSE",
        [17] = "SCFA_DRAGBUILD",
        [18] = "SCFA_OVERLAYANTINAVY",
        [19] = "SCFA_OVERLAYSONAR",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SIZE4",
        [24] = "SCFA_SORTDEFENSE",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH1",
        [27] = "SCFA_VISIBLETORECON",
        [28] = "NAVAL",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1301/LOD0/ucs1301.sananimation",
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.5,
                    ["z"] = -0.23000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.36,
                    ["z"] = 0.112,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.56,
                    ["z"] = 0.09400000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.84,
                    ["z"] = -0.23000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.8,
                    ["z"] = 0.112,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 175,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
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
                    ["aimTolerance"] = 30,
                    ["defaultPitchAdjustment"] = -20,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 15,
                    ["pitchMin"] = -55,
                    ["pitchSpeed"] = 35,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 25,
                },
            },
            ["damage"] = 150,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs1301/muzzle_turret01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
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
            ["muzzleSalvoDelay"] = 0.8,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0053",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Turret01",
                ["sourceProjectile"] = "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Navy",
            ["scoSourceLabel"] = "Turret01",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Turret01",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Above",
        },
    },
}
