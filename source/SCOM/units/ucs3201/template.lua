-- ucs3201: Transcender
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "permanent_open",
            ["mapping"] = "UAB2304 -> ucs3201",
            ["primaryClip"] = {
                ["durationSeconds"] = 2.6666667,
                ["key"] = "source_animopen",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 0,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB2304/UAB2304_unit.bp",
            ["sourceBlueprintSha256"] = "66bec16f278856954b999095ca49e2a1eb5133b4efccb21756fdebd21218ccd7",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 2.6666667,
                    ["frames"] = 81,
                    ["key"] = "source_animopen",
                    ["name"] = "AnimOpen",
                    ["rate"] = 1,
                    ["role"] = "permanent_open",
                    ["sha256"] = "171ed6314bd460d00c8cc2344d683745b473951eff0335a42a5c45cb0a0379eb",
                    ["source"] = "units/UAB2304/UAB2304_Aopen.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "6cd6aa94bd3ae6a6c15fc691b8172ce76dd80fa1ba44d9a4d9e5092468dbcde1",
            ["sourceScript"] = "units/UAB2304/UAB2304_script.lua",
            ["sourceScriptSha256"] = "b025eef07cbc3550c0b71c785fa24c0bd314f8dd3a02495ce4eb4b6e1f20a2b8",
            ["stateOwner"] = "OnStopBeingBuilt plays AnimOpen once at source rate 1 with Clamp playback and retains its endpoint.",
            ["targetAnimation"] = {
                ["bytes"] = 252706,
                ["path"] = "Units/ucs3201/LOD0/ucs3201.sananimation",
                ["sha256"] = "1f7811263908a44825e13bf7bdfddc69e49afefec9fbd16a8b903d1f5db580b0",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 335089,
                ["path"] = "Units/ucs3201/LOD0/ucs3201_lod0.sanmodel",
                ["sha256"] = "feba9df46e49f13e90dab58147b8a5998ad822f4143d8e53ac0ffe54f799c771",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 15297,
                ["path"] = "Units/ucs3201/LOD0/ucs3201.sanskeleton",
                ["sha256"] = "c986def175940182a4e70aab188146c8c3125f5028ac855560e2f71d44cf52a9",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 28,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 2,
                    ["z"] = 2,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = -0.5,
                    ["offsetZ"] = -0.5,
                    ["sizeX"] = 2,
                    ["sizeZ"] = 2,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB2304/UAB2304_unit.bp",
            ["sourceBlueprintSha256"] = "66bec16f278856954b999095ca49e2a1eb5133b4efccb21756fdebd21218ccd7",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ANTIAIR",
                [3] = "BUILTBYTIER3COMMANDER",
                [4] = "BUILTBYTIER3ENGINEER",
                [5] = "DEFENSE",
                [6] = "DRAGBUILD",
                [7] = "OVERLAYANTIAIR",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "SIZE4",
                [12] = "SORTDEFENSE",
                [13] = "STRUCTURE",
                [14] = "TECH3",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB2304",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3201",
            ["weapons"] = {
                [1] = {
                    ["label"] = "AntiAirMissiles",
                    ["muzzleSalvoSize"] = 2,
                    ["projectilesPerOnFire"] = 2,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Turret_Muzzle01",
                                [2] = "Turret_Muzzle02",
                            },
                            ["rackBone"] = "Turret_Barrel",
                        },
                    },
                    ["rateOfFire"] = 0.28,
                    ["reloadTime"] = 3.571428571428571,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp",
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixTranscender"] = {
            ["homing"] = true,
            ["isolatedExistingProjectile"] = true,
            ["projectileTemplate"] = "paa341",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.04999999999999993,
                ["z"] = 0,
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
            ["y"] = 0.04999999999999993,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 1.4,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10500,
            ["regen"] = 0,
            ["value"] = 10500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 800,
            ["energy"] = 8000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Transcender",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Transcender",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucs3201",
        ["unitTypeName"] = "Transcender",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CHOSEN",
        [4] = "DEFENCE",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ANTIAIR",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DEFENSE",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_OVERLAYANTIAIR",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SIZE4",
        [19] = "SCFA_SORTDEFENSE",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3201/LOD0/ucs3201.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3201/LOD0/ucs3201.sananimation",
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
                    ["x"] = 0.108,
                    ["y"] = 0.3999999999999999,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.30199999999999994,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.44199999999999995,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.6379999999999999,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.6099999999999999,
                    ["z"] = 0.108,
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
                ["y"] = 0.04999999999999993,
                ["z"] = 0,
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
                    ["aimBone"] = "Turret_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 10,
                    ["defaultPitchAdjustment"] = -1,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 105,
                    ["pitchMin"] = -55,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["reduceMuzzleVelocityToTarget"] = false,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 360,
                    ["yawMin"] = -360,
                    ["yawSpeed"] = 180,
                },
            },
            ["damage"] = 600,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs3201/muzzle_antiairmissiles.sanvfx",
            },
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
                        [1] = "Turret_Muzzle01",
                        [2] = "Turret_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.6,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
                ["Turret_Muzzle02"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
            },
            ["projectileLifetime"] = 5,
            ["projectileTemplate"] = "psf0049",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 3.571428571428571,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0ad044add942af4aa3d8b092aa2ba5a592074db5df0a27564d831411ea86ed1d",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AntiAirMissiles",
                ["sourceProjectile"] = "/projectiles/AAAZealotMissile01/AAAZealotMissile01_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "AntiAirMissiles",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AntiAirMissiles",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
