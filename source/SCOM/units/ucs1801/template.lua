-- ucs1801: Sylph
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
                    ["waterVisionRadius"] = 32,
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
            ["sourceBlueprint"] = "units/UAS0203/UAS0203_unit.bp",
            ["sourceBlueprintSha256"] = "849a1a43346211abb8e54137d1504252d95e9c4202b110de82a2440296d7decc",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ANTINAVY",
                [3] = "BUILTBYEXPERIMENTALSUB",
                [4] = "BUILTBYTIER1FACTORY",
                [5] = "BUILTBYTIER2FACTORY",
                [6] = "BUILTBYTIER3FACTORY",
                [7] = "MOBILE",
                [8] = "NAVAL",
                [9] = "OVERLAYANTINAVY",
                [10] = "OVERLAYSONAR",
                [11] = "PRODUCTSC1",
                [12] = "RECLAIMABLE",
                [13] = "SELECTABLE",
                [14] = "SUBMERSIBLE",
                [15] = "T1SUBMARINE",
                [16] = "TECH1",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = -1.5,
            ["sourceId"] = "UAS0203",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 6,
            ["sourceMotionType"] = "RULEUMT_SurfacingSub",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs1801",
            ["weapons"] = {
                [1] = {
                    ["label"] = "Torpedo01",
                    ["muzzleSalvoSize"] = 2,
                    ["projectilesPerOnFire"] = 2,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "muzzle_01",
                                [2] = "Muzzle_02",
                            },
                            ["rackBone"] = "muzzle_01",
                        },
                    },
                    ["rateOfFire"] = 0.25,
                    ["reloadTime"] = 4,
                    ["sourceCategory"] = "Anti Navy",
                    ["sourceProjectile"] = "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp",
                },
            },
        },
        ["seaParityWeaponSemantics"] = {
            ["Torpedo01"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0.05,
                ["y"] = 0,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 1.5,
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
            ["y"] = 0,
            ["z"] = -0.01,
        },
        ["collisionSize"] = {
            ["x"] = 0.35,
            ["y"] = 0.5,
            ["z"] = 1.85,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 550,
            ["regen"] = 0,
            ["value"] = 550,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1440,
        ["cost"] = {
            ["alloys"] = 360,
            ["energy"] = 2880,
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
        ["displayName"] = "Sylph",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Sylph",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucs1801",
        ["unitTypeName"] = "Sylph",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 6,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 6,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 80,
        ["sortOrder"] = 1,
        ["speed"] = 6,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
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
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CHOSEN",
        [6] = "MOBILE",
        [7] = "NAVAL",
        [8] = "TECH1",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_ANTINAVY",
        [12] = "SCFA_BUILTBYEXPERIMENTALSUB",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_MOBILE",
        [17] = "SCFA_NAVAL",
        [18] = "SCFA_OVERLAYANTINAVY",
        [19] = "SCFA_OVERLAYSONAR",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SUBMERSIBLE",
        [24] = "SCFA_T1SUBMARINE",
        [25] = "SCFA_TECH1",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucs1801/LOD0/ucs1801.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucs1801/LOD0/ucs1801.sananimation",
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
                    ["x"] = 0.113,
                    ["y"] = 0.125,
                    ["z"] = -0.38000000000000006,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.026999999999999996,
                    ["y"] = 0.09,
                    ["z"] = 0.323,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.14,
                    ["z"] = 0.28600000000000003,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.113,
                    ["y"] = 0.21,
                    ["z"] = -0.38000000000000006,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.026999999999999996,
                    ["y"] = 0.2,
                    ["z"] = 0.323,
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
                ["y"] = 0,
                ["z"] = -0.01,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 1.5,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "muzzle_01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "muzzle_01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 75,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs1801/muzzle_torpedo01.sanvfx",
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
                        [1] = "muzzle_01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.8,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Muzzle_02"] = {
                    ["aimController"] = "muzzle_01",
                },
                ["muzzle_01"] = {
                    ["aimController"] = "muzzle_01",
                },
            },
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0053",
            ["rangeMax"] = 32,
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
    },
}
