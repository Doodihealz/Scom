-- ucl4001: Silencer
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
                    ["waterVisionRadius"] = 35,
                },
                ["runtimeSupported"] = {
                    ["visionRadius"] = 16,
                },
            },
            ["movementCompatibility"] = "Sanctuary routes UnderWater but has no FA SurfacingSub transition state machine; the functional WaterSurface fallback retains source speed/acceleration/turn while submerge depth stays provenance.",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 2,
                    ["z"] = 5,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAS0304/UAS0304_unit.bp",
            ["sourceBlueprintSha256"] = "501eff2d24fcf9b447af0f15ffa81aa5976bf0f3049e79e7003ba1f4ba8c926c",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3FACTORY",
                [3] = "INDIRECTFIRE",
                [4] = "MOBILE",
                [5] = "NAVAL",
                [6] = "NUKE",
                [7] = "NUKESUB",
                [8] = "OVERLAYINDIRECTFIRE",
                [9] = "OVERLAYSONAR",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SILO",
                [14] = "SUBMERSIBLE",
                [15] = "TECH3",
                [16] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = -2,
            ["sourceId"] = "UAS0304",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 3.5,
            ["sourceMotionType"] = "RULEUMT_SurfacingSub",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl4001",
            ["weapons"] = {
                [1] = {
                    ["label"] = "CruiseMissiles",
                    ["muzzleSalvoSize"] = 5,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_01",
                            },
                            ["rackBone"] = "Muzzle_01",
                        },
                    },
                    ["rateOfFire"] = 0.05,
                    ["reloadTime"] = 20,
                    ["sourceCategory"] = "Missile",
                    ["sourceProjectile"] = "/projectiles/AIFMissileSerpentine02/AIFMissileSerpentine02_proj.bp",
                },
                [2] = {
                    ["label"] = "NukeMissiles",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_05",
                            },
                            ["rackBone"] = "Muzzle_05",
                        },
                    },
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Missile",
                    ["sourceProjectile"] = "/projectiles/AIFQuantumWarhead03/AIFQuantumWarhead03_proj.bp",
                },
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["scoStrategicSilo"] = {
            ["buildOrder"] = "ManualFire1",
            ["buildPower"] = 1080,
            ["buildTime"] = 324000,
            ["cost"] = {
                ["alloys"] = 15000,
                ["energy"] = 1800000,
            },
            ["damageFriendly"] = true,
            ["defaultAutoBuild"] = true,
            ["initialAmmo"] = 0,
            ["initialProjectileSpeed"] = 1,
            ["innerDamage"] = {
                ["amount"] = 75000,
                ["radius"] = 30,
                ["ticks"] = 24,
                ["totalTime"] = 0,
            },
            ["launchOrder"] = "ManualFire2",
            ["maxAmmo"] = 3,
            ["muzzle"] = "Muzzle_05",
            ["outerDamage"] = {
                ["amount"] = 500,
                ["radius"] = 40,
                ["ticks"] = 20,
                ["totalTime"] = 0,
            },
            ["projectileLifetime"] = 600,
            ["projectileTemplate"] = "psn005",
            ["rangeMax"] = 1024,
            ["rangeMin"] = 128,
            ["terrainClearance"] = 0.05,
            ["version"] = "1.0.0",
        },
        ["seaParityUnsupported"] = {},
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.025000000000000022,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 2.2,
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
            ["x"] = 0,
            ["y"] = -0.025000000000000022,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.7,
            ["z"] = 3.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 1080,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3750,
            ["regen"] = 0,
            ["value"] = 3750,
        },
    },
    ["economy"] = {
        ["buildTime"] = 20000,
        ["cost"] = {
            ["alloys"] = 10000,
            ["energy"] = 800000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortNavalUnit",
        },
        ["displayName"] = "Silencer",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Silencer",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["ManualFire1"] = true,
            ["ManualFire2"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["StrategicManualLaunch"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ucl4001",
        ["unitTypeName"] = "Silencer",
    },
    ["intel"] = {
        ["visionRadius"] = 16,
    },
    ["movement"] = {
        ["acceleration"] = 3.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 3.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 50,
        ["sortOrder"] = 1,
        ["speed"] = 3.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 20,
            ["outerRadius"] = 175,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_FACTORY",
        [2] = "CHOSEN",
        [3] = "INDIRECT_FIRE",
        [4] = "MOBILE",
        [5] = "NAVAL",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3FACTORY",
        [10] = "SCFA_INDIRECTFIRE",
        [11] = "SCFA_MOBILE",
        [12] = "SCFA_NAVAL",
        [13] = "SCFA_NUKE",
        [14] = "SCFA_NUKESUB",
        [15] = "SCFA_OVERLAYINDIRECTFIRE",
        [16] = "SCFA_OVERLAYSONAR",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SILO",
        [21] = "SCFA_SUBMERSIBLE",
        [22] = "SCFA_TECH3",
        [23] = "SCFA_VISIBLETORECON",
        [24] = "NUKE",
        [25] = "SILO",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucl4001/LOD0/ucl4001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl4001/LOD0/ucl4001.sananimation",
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
                    ["x"] = 0.126,
                    ["y"] = 0.14999999999999997,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.10099999999999998,
                    ["z"] = 0.63,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.17099999999999999,
                    ["z"] = 0.56,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.26899999999999996,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.25499999999999995,
                    ["z"] = 0.63,
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
                ["x"] = 0,
                ["y"] = -0.025000000000000022,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 2.2,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Muzzle_01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Muzzle_01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 1500,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl4001/muzzle_cruisemissiles.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Water",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_01",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 1.5,
            ["muzzleSalvoSize"] = 5,
            ["muzzles"] = {
                ["Muzzle_01"] = {
                    ["aimController"] = "Muzzle_01",
                },
            },
            ["projectileLifetime"] = 50,
            ["projectileTemplate"] = "psf0074",
            ["rangeMax"] = 175,
            ["rangeMin"] = 20,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 20,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "e2759f1dbf0b1c023bd35eb4aa443c7cf953673ba0f5a5284fc5545a8a423437",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissiles",
                ["sourceProjectile"] = "/projectiles/AIFMissileSerpentine02/AIFMissileSerpentine02_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceCategory"] = "Missile",
            ["scoSourceLabel"] = "CruiseMissiles",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissiles",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
