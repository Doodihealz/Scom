-- ucs3402: Patron
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "permanent_open",
            ["mapping"] = "UAB4302 -> ucs3402",
            ["primaryClip"] = {
                ["durationSeconds"] = 3,
                ["key"] = "source_animopen",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 0,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4302/UAB4302_unit.bp",
            ["sourceBlueprintSha256"] = "d72db5e3fc2233509f6de9b3cc3351b8c4e053351fd4c14b5be4aa9cea23ed5a",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 3,
                    ["frames"] = 31,
                    ["key"] = "source_animopen",
                    ["name"] = "AnimOpen",
                    ["rate"] = 1,
                    ["role"] = "permanent_open",
                    ["sha256"] = "ebf785420e89f22c6ceee428b2bf984ab5ad78a6bceabd6360ce4c0683ca03de",
                    ["source"] = "units/UAB4302/UAB4302_Aopen.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "376ba255fbe230e6998cc241e68e4152e1c4202017dbbf164de285eb8cc5cbd1",
            ["sourceScript"] = "units/UAB4302/UAB4302_script.lua",
            ["sourceScriptSha256"] = "80aeb59d0226392ee9f8aacfa7d9e450774a758f27b2f10a89d170699f128a16",
            ["stateOwner"] = "OnStopBeingBuilt plays AnimOpen once at source rate 1 with Clamp playback and retains its endpoint.",
            ["targetAnimation"] = {
                ["bytes"] = 78834,
                ["path"] = "Units/ucs3402/LOD0/ucs3402.sananimation",
                ["sha256"] = "3bf545828aae952c1af6476d7679d2216703fe85c0c7c8cd4af3c7fa4652f5d6",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 241477,
                ["path"] = "Units/ucs3402/LOD0/ucs3402_lod0.sanmodel",
                ["sha256"] = "2ab419dec4193d4b56528c528ea562e21ffdfebd0ca0ce3773085bcdf8511bda",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 11982,
                ["path"] = "Units/ucs3402/LOD0/ucs3402.sanskeleton",
                ["sha256"] = "57031aa0094ecbc73ad131892ca7870411e3faecd5c273781cd1edbd3ac6d3d8",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 20,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 3,
                    ["z"] = 3,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = -0.5,
                    ["offsetZ"] = -0.5,
                    ["sizeX"] = 3,
                    ["sizeZ"] = 3,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4302/UAB4302_unit.bp",
            ["sourceBlueprintSha256"] = "d72db5e3fc2233509f6de9b3cc3351b8c4e053351fd4c14b5be4aa9cea23ed5a",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ANTIMISSILE",
                [3] = "BUILTBYTIER3COMMANDER",
                [4] = "BUILTBYTIER3ENGINEER",
                [5] = "DEFENSE",
                [6] = "DRAGBUILD",
                [7] = "OVERLAYDEFENSE",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "SILO",
                [12] = "SIZE8",
                [13] = "SORTDEFENSE",
                [14] = "STRUCTURE",
                [15] = "TECH3",
                [16] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB4302",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3402",
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
                                [1] = "Turret",
                            },
                            ["rackBone"] = "Turret",
                        },
                    },
                    ["rateOfFire"] = 0.6,
                    ["reloadTime"] = 1.6666666666666667,
                    ["sourceCategory"] = "Defense",
                    ["sourceProjectile"] = "/projectiles/AIMSaintAntiNuke01/AIMSaintAntiNuke01_proj.bp",
                },
            },
        },
        ["scoSourceInterception"] = {
            ["permanentOpen"] = {
                ["animation"] = {
                    ["clipName"] = "AnimOpen",
                    ["playbackMode"] = 0,
                    ["sanAnimationPath"] = "Units/ucs3402/LOD0/ucs3402.sananimation",
                },
                ["duration"] = 3,
                ["key"] = "sco_source_permanent",
            },
            ["silo"] = {
                ["autoIntercept"] = true,
                ["buildPower"] = 1080,
                ["buildTime"] = 259200,
                ["charge"] = 0,
                ["cost"] = {
                    ["alloys"] = 3600,
                    ["energy"] = 360000,
                },
                ["cycleReload"] = 0,
                ["damage"] = 30,
                ["damageRadius"] = 0,
                ["deployDuration"] = 0,
                ["deployKey"] = "sco_source_launch",
                ["deployRate"] = 1,
                ["initialAmmo"] = 0,
                ["maxAmmo"] = 7,
                ["muzzleVelocity"] = 90,
                ["muzzles"] = {
                    [1] = "Turret",
                },
                ["nukeRings"] = {},
                ["preserveAttack"] = false,
                ["projectile"] = "psf0079",
                ["rangeMax"] = 90,
                ["rangeMin"] = 0,
                ["reload"] = 1.6666666666666667,
                ["repackTimeout"] = 0,
                ["role"] = "launcher",
                ["sourceId"] = "UAB4302",
                ["sourceLabel"] = "MissileRack",
                ["sourceStockpile"] = true,
                ["version"] = "1.0.0",
            },
            ["sourceId"] = "UAB4302",
            ["targetId"] = "ucs3402",
            ["weapons"] = {
                ["MissileRack"] = {
                    ["counted"] = true,
                    ["damage"] = 30,
                    ["interval"] = 0.1,
                    ["muzzleVelocity"] = 90,
                    ["muzzles"] = {
                        [1] = "Turret",
                    },
                    ["projectile"] = "psf0079",
                    ["rangeMax"] = 90,
                    ["rangeMin"] = 0,
                    ["reload"] = 1.6666666666666667,
                    ["sourceIndex"] = 1,
                    ["sourceLabel"] = "MissileRack",
                    ["targetClass"] = "strategic",
                },
            },
        },
        ["scoTactical"] = {
            ["autoIntercept"] = true,
            ["buildPower"] = 1080,
            ["buildTime"] = 259200,
            ["charge"] = 0,
            ["cost"] = {
                ["alloys"] = 3600,
                ["energy"] = 360000,
            },
            ["cycleReload"] = 0,
            ["damage"] = 30,
            ["damageRadius"] = 0,
            ["deployDuration"] = 0,
            ["deployKey"] = "sco_source_launch",
            ["deployRate"] = 1,
            ["initialAmmo"] = 0,
            ["maxAmmo"] = 7,
            ["muzzleVelocity"] = 90,
            ["muzzles"] = {
                [1] = "Turret",
            },
            ["nukeRings"] = {},
            ["preserveAttack"] = false,
            ["projectile"] = "psf0079",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["reload"] = 1.6666666666666667,
            ["repackTimeout"] = 0,
            ["role"] = "launcher",
            ["sourceId"] = "UAB4302",
            ["sourceLabel"] = "MissileRack",
            ["sourceStockpile"] = true,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.04999999999999999,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.25,
                ["y"] = 1.25,
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
            ["y"] = 0.04999999999999999,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.75,
            ["y"] = 0.6,
            ["z"] = 1.75,
        },
    },
    ["construction"] = {
        ["buildPower"] = 1080,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3800,
            ["regen"] = 0,
            ["value"] = 3800,
        },
    },
    ["economy"] = {
        ["buildTime"] = 4500,
        ["cost"] = {
            ["alloys"] = 7500,
            ["energy"] = 105000,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Patron",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Patron",
        ["orders"] = {
            ["ManualFire1"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ucs3402",
        ["unitTypeName"] = "Patron",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 90,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["skirtSize"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["tags"] = {
        [1] = "ANTI_PROJECTILE",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CHOSEN",
        [4] = "DEFENCE",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ANTIMISSILE",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DEFENSE",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_OVERLAYDEFENSE",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SILO",
        [19] = "SCFA_SIZE8",
        [20] = "SCFA_SORTDEFENSE",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TECH3",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["sco_source_permanent"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3402/LOD0/ucs3402.sananimation",
            },
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3402/LOD0/ucs3402.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3402/LOD0/ucs3402.sananimation",
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
                    ["x"] = 0.315,
                    ["y"] = 0.19999999999999998,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 0.15799999999999997,
                    ["z"] = 0.315,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.35000000000000003,
                    ["y"] = 0.218,
                    ["z"] = 0.28,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 0.302,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 0.29,
                    ["z"] = 0.315,
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
                ["y"] = 0.04999999999999999,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.25,
                ["y"] = 1.25,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 60,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 90,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 30,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret"] = {
                    ["aimController"] = "Turret",
                },
            },
            ["projectileLifetime"] = 1.25,
            ["projectileTemplate"] = "psf0079",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1.6666666666666667,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "889c17e6fb8a833d67ad146ffc55e8cd93724071f2a99e85dcaa379c7941525a",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack",
                ["sourceProjectile"] = "/projectiles/AIMSaintAntiNuke01/AIMSaintAntiNuke01_proj.bp",
            },
            ["scoSourceCategory"] = "Defense",
            ["scoSourceInterceptionLabel"] = "MissileRack",
            ["scoSourceLabel"] = "MissileRack",
            ["scoTacticalOwned"] = true,
            ["targetWaterLimits"] = "Above",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoTactical"] = UnitTemplate["additions"]["scoSourceInterception"]["silo"]
UnitTemplate["visuals"]["animations"]["sco_source_permanent"] = UnitTemplate["additions"]["scoSourceInterception"]["permanentOpen"]["animation"]
