-- ucl4003: Tempest
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint01",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["sonarRadius"] = 250,
                    ["waterVisionRadius"] = 100,
                },
                ["runtimeSupported"] = {
                    ["radarRadius"] = 150,
                    ["visionRadius"] = 100,
                },
            },
            ["movementCompatibility"] = "Sanctuary routes UnderWater but has no FA SurfacingSub transition state machine; the functional WaterSurface fallback retains source speed/acceleration/turn while submerge depth stays provenance.",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 16,
                    ["z"] = 16,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 16,
                    ["sizeZ"] = 16,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAS0401/UAS0401_unit.bp",
            ["sourceBlueprintSha256"] = "42ad52043c056a4d0d9ac9471449f621eda818dd37c0699eee8e8bd0c3bf05e3",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BATTLESHIP",
                [3] = "BUILTBYTIER3COMMANDER",
                [4] = "BUILTBYTIER3ENGINEER",
                [5] = "CARRIER",
                [6] = "DIRECTFIRE",
                [7] = "DRAGBUILD",
                [8] = "EXPERIMENTAL",
                [9] = "FACTORY",
                [10] = "INTELLIGENCE",
                [11] = "MOBILE",
                [12] = "NAVAL",
                [13] = "NEEDMOBILEBUILD",
                [14] = "OVERLAYANTINAVY",
                [15] = "OVERLAYDEFENSE",
                [16] = "OVERLAYDIRECTFIRE",
                [17] = "OVERLAYRADAR",
                [18] = "OVERLAYSONAR",
                [19] = "PRODUCTSC1",
                [20] = "RECLAIMABLE",
                [21] = "SELECTABLE",
                [22] = "SHOWATTACKRETICLE",
                [23] = "SHOWQUEUE",
                [24] = "SUBMERSIBLE",
                [25] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = -5,
            ["sourceId"] = "UAS0401",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 2.5,
            ["sourceMotionType"] = "RULEUMT_SurfacingSub",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl4003",
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
                            ["rackBone"] = "Turret_Barrel02",
                        },
                    },
                    ["rateOfFire"] = 0.1,
                    ["reloadTime"] = 10,
                    ["sourceCategory"] = "Direct Fire Naval",
                    ["sourceProjectile"] = "/projectiles/ADFOblivionCannon04/ADFOblivionCannon04_proj.bp",
                },
                [2] = {
                    ["label"] = "Torpedo01",
                    ["muzzleSalvoSize"] = 6,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Torpedo_Muzzle01",
                                [2] = "Torpedo_Muzzle02",
                                [3] = "Torpedo_Muzzle03",
                                [4] = "Torpedo_Muzzle04",
                                [5] = "Torpedo_Muzzle05",
                                [6] = "Torpedo_Muzzle06",
                            },
                            ["rackBone"] = "Torpedo_Muzzle01",
                        },
                    },
                    ["rateOfFire"] = 0.25,
                    ["reloadTime"] = 4,
                    ["sourceCategory"] = "Anti Navy",
                    ["sourceProjectile"] = "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp",
                },
                [3] = {
                    ["label"] = "AntiTorpedo01",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Anti_Torpedo_Muzzle01",
                                [2] = "Anti_Torpedo_Muzzle02",
                            },
                            ["rackBone"] = "Anti_Torpedo_Muzzle01",
                        },
                    },
                    ["rateOfFire"] = 1,
                    ["reloadTime"] = 1,
                    ["sourceCategory"] = "Defense",
                    ["sourceProjectile"] = "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp",
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixTempest"] = {
            ["combatWeaponCount"] = 2,
            ["openAnimationKey"] = "source_animaopen01",
            ["restAnimationKey"] = "walk",
            ["runtimeLifecycleRequired"] = true,
            ["version"] = "1.0.0",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scoSeaParityMinimumWaterDepth"] = 0,
        ["scoSeaParityPlacementMode"] = "WaterOnly",
        ["scoSourceDeath"] = {
            ["hasMovement"] = true,
            ["sourceId"] = "UAS0401",
            ["variants"] = {
                [1] = {
                    ["durationSeconds"] = 17.5,
                    ["key"] = "scoSourceDeath01",
                    ["rateMax"] = 1.5,
                    ["rateMin"] = 0.5,
                    ["weight"] = 100,
                },
            },
        },
        ["scoSourceInterception"] = {
            ["sourceId"] = "UAS0401",
            ["weapons"] = {
                ["AntiTorpedo01"] = {
                    ["counted"] = false,
                    ["damage"] = 3,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 80,
                    ["muzzles"] = {
                        [1] = "Anti_Torpedo_Muzzle01",
                        [2] = "Anti_Torpedo_Muzzle02",
                    },
                    ["projectile"] = "psf0177",
                    ["rangeMax"] = 45,
                    ["rangeMin"] = 15,
                    ["reload"] = 1,
                    ["sourceIndex"] = 3,
                    ["sourceLabel"] = "AntiTorpedo01",
                    ["targetClass"] = "torpedo",
                },
            },
        },
        ["seaParityUnsupported"] = {
            ["movingNavalFactory"] = true,
            ["projectileInterception"] = true,
        },
        ["seaParityWeaponSemantics"] = {
            ["Torpedo01"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.625,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 8.5,
                ["y"] = 8.5,
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
            ["y"] = 1.625,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 12,
            ["y"] = 4,
            ["z"] = 12,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Attachpoint01",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
        },
        ["buildPower"] = 240,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 35000,
            ["regen"] = 0,
            ["value"] = 35000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 12000,
        ["cost"] = {
            ["alloys"] = 28000,
            ["energy"] = 350000,
        },
    },
    ["footprint"] = {
        ["x"] = 16,
        ["y"] = 16,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortNavalUnit",
        },
        ["displayName"] = "Tempest",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_experimental1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Tempest",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["requiresWaterPlacement"] = true,
        ["tpId"] = "ucl4003",
        ["unitTypeName"] = "Tempest",
    },
    ["intel"] = {
        ["radarRadius"] = 150,
        ["visionRadius"] = 100,
    },
    ["movement"] = {
        ["acceleration"] = 2.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 2.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 30,
        ["sortOrder"] = 1,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 150,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 150,
        },
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 80,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 100,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 100,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "CHOSEN",
        [3] = "DIRECT_FIRE",
        [4] = "FACTORY",
        [5] = "INTEL",
        [6] = "MOBILE",
        [7] = "NAVAL",
        [8] = "RADAR",
        [9] = "TECH4",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BATTLESHIP",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CARRIER",
        [16] = "SCFA_DIRECTFIRE",
        [17] = "SCFA_DRAGBUILD",
        [18] = "SCFA_EXPERIMENTAL",
        [19] = "SCFA_FACTORY",
        [20] = "SCFA_INTELLIGENCE",
        [21] = "SCFA_MOBILE",
        [22] = "SCFA_NAVAL",
        [23] = "SCFA_NEEDMOBILEBUILD",
        [24] = "SCFA_OVERLAYANTINAVY",
        [25] = "SCFA_OVERLAYDEFENSE",
        [26] = "SCFA_OVERLAYDIRECTFIRE",
        [27] = "SCFA_OVERLAYRADAR",
        [28] = "SCFA_OVERLAYSONAR",
        [29] = "SCFA_PRODUCTSC1",
        [30] = "SCFA_RECLAIMABLE",
        [31] = "SCFA_SELECTABLE",
        [32] = "SCFA_SHOWATTACKRETICLE",
        [33] = "SCFA_SHOWQUEUE",
        [34] = "SCFA_SUBMERSIBLE",
        [35] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSourceDeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl4003/LOD0/ucl4003.sananimation",
            },
            ["source_animadeath01"] = {
                ["clipName"] = "AnimAdeath01",
                ["sanAnimationPath"] = "Units/ucl4003/LOD0/ucl4003.sananimation",
            },
            ["source_animaopen01"] = {
                ["clipName"] = "AnimAopen01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl4003/LOD0/ucl4003.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl4003/LOD0/ucl4003.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 2.16,
                    ["y"] = 2.625,
                    ["z"] = -2.4000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -2.64,
                    ["y"] = 2.3449999999999998,
                    ["z"] = 2.16,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 2.4000000000000004,
                    ["y"] = 2.745,
                    ["z"] = 1.92,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 2.16,
                    ["y"] = 3.3049999999999997,
                    ["z"] = -2.4000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -2.64,
                    ["y"] = 3.225,
                    ["z"] = 2.16,
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
                ["y"] = 1.625,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 8.5,
                ["y"] = 8.5,
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
                    ["defaultPitchAdjustment"] = 40,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel01",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -10,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 10,
                },
            },
            ["damage"] = 6000,
            ["damageRadius"] = 5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl4003/muzzle_maingun.sanvfx",
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
            ["projectileLifetime"] = 10,
            ["projectileTemplate"] = "psf0064",
            ["rangeMax"] = 150,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 10,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "ada003e83d12ce68d15d98de4378c67f702d9cf721428f2e2984a4f7b8069122",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/ADFOblivionCannon04/ADFOblivionCannon04_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceCategory"] = "Direct Fire Naval",
            ["scoSourceLabel"] = "MainGun",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Torpedo_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Torpedo_Muzzle01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Torpedo_Muzzle01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 235,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl4003/muzzle_torpedo01.sanvfx",
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
                        [1] = "Torpedo_Muzzle01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Torpedo_Muzzle02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Torpedo_Muzzle03",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Torpedo_Muzzle04",
                    },
                },
                [5] = {
                    ["muzzles"] = {
                        [1] = "Torpedo_Muzzle05",
                    },
                },
                [6] = {
                    ["muzzles"] = {
                        [1] = "Torpedo_Muzzle06",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.5,
            ["muzzleSalvoSize"] = 6,
            ["muzzles"] = {
                ["Torpedo_Muzzle01"] = {
                    ["aimController"] = "Torpedo_Muzzle01",
                },
                ["Torpedo_Muzzle02"] = {
                    ["aimController"] = "Torpedo_Muzzle01",
                },
                ["Torpedo_Muzzle03"] = {
                    ["aimController"] = "Torpedo_Muzzle01",
                },
                ["Torpedo_Muzzle04"] = {
                    ["aimController"] = "Torpedo_Muzzle01",
                },
                ["Torpedo_Muzzle05"] = {
                    ["aimController"] = "Torpedo_Muzzle01",
                },
                ["Torpedo_Muzzle06"] = {
                    ["aimController"] = "Torpedo_Muzzle01",
                },
            },
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0053",
            ["rangeMax"] = 80,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "16ff14ee2eb91421198b500169247792ebd48a503ce40357baf915d35bc9934b",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "Torpedo01",
                ["sourceProjectile"] = "/projectiles/AANTorpedo01/AANTorpedo01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Navy",
            ["scoSourceLabel"] = "Torpedo01",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "Torpedo01",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Anti_Torpedo_Muzzle01",
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Anti_Torpedo_Muzzle01",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 0,
                    ["projectileSpeed"] = 80,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Anti_Torpedo_Muzzle01",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 3,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucl4003/muzzle_antitorpedo01.sanvfx",
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
                        [1] = "Anti_Torpedo_Muzzle01",
                        [2] = "Anti_Torpedo_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Anti_Torpedo_Muzzle01"] = {
                    ["aimController"] = "Anti_Torpedo_Muzzle01",
                },
                ["Anti_Torpedo_Muzzle02"] = {
                    ["aimController"] = "Anti_Torpedo_Muzzle01",
                },
            },
            ["name"] = "AntiTorpedo01",
            ["projectileLifetime"] = 1.5,
            ["projectileTemplate"] = "psf0177",
            ["rangeMax"] = 45,
            ["rangeMin"] = 15,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 1,
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "42ad52043c056a4d0d9ac9471449f621eda818dd37c0699eee8e8bd0c3bf05e3",
                ["sourceId"] = "UAS0401",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "AntiTorpedo01",
            },
            ["scoFaSourceWeapon"] = {
                ["BallisticArc"] = "RULEUBA_None",
                ["CollideFriendly"] = false,
                ["Damage"] = 3,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Quasar Anti Torpedo",
                ["FireTargetLayerCapsTable"] = {
                    ["Sub"] = "Sub|Water",
                    ["Water"] = "Sub|Water",
                },
                ["FiringTolerance"] = 180,
                ["Label"] = "AntiTorpedo01",
                ["LeadTarget"] = false,
                ["MaxRadius"] = 45,
                ["MinRadius"] = 15,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["MuzzleVelocity"] = 80,
                ["ProjectileId"] = "/projectiles/AIMAntiTorpedo02/AIMAntiTorpedo02_proj.bp",
                ["ProjectileLifetime"] = 1.5,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Anti_Torpedo_Muzzle01",
                            [2] = "Anti_Torpedo_Muzzle02",
                        },
                        ["RackBone"] = "Anti_Torpedo_Muzzle01",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 10,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RangeCategory"] = "UWRC_Countermeasure",
                ["RateOfFire"] = 1,
                ["TargetCheckInterval"] = 0.5,
                ["TargetRestrictDisallow"] = "UNTARGETABLE",
                ["TargetRestrictOnlyAllow"] = "TORPEDO",
                ["TargetType"] = "RULEWTT_Projectile",
                ["TrackingRadius"] = 1.5,
                ["Turreted"] = false,
                ["WeaponCategory"] = "Defense",
            },
            ["scoFaSourceWeaponIndex"] = 3,
            ["scoSourceInterceptionLabel"] = "AntiTorpedo01",
            ["scoTacticalOwned"] = true,
        },
    },
}
