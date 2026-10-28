-- ucs2101: Miasma
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "permanent_open",
            ["mapping"] = "UAB2303 -> ucs2101",
            ["primaryClip"] = {
                ["durationSeconds"] = 2.3333333,
                ["key"] = "source_animopen",
                ["rate"] = 1,
            },
            ["rotatorCount"] = 0,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB2303/UAB2303_unit.bp",
            ["sourceBlueprintSha256"] = "f056166ac1588ee419d833f890aefbf3db56798f05bfc914925c44a8dfc98bac",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 2.3333333,
                    ["frames"] = 71,
                    ["key"] = "source_animopen",
                    ["name"] = "AnimOpen",
                    ["rate"] = 1,
                    ["role"] = "permanent_open",
                    ["sha256"] = "d66b774506a644d2b496586471e72a0cf135cc2069e672e883b4a3580f84a41d",
                    ["source"] = "units/UAB2303/UAB2303_Aopen.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "052fceab0740a7f523166cc8500195fd7e2b89b24d06adb772ac2e9b63f7b4eb",
            ["sourceScript"] = "units/UAB2303/UAB2303_script.lua",
            ["sourceScriptSha256"] = "b73d3b44b2882ba5d190a392ae82639a5ff46580294d33ff566eaafb00ee5833",
            ["stateOwner"] = "OnStopBeingBuilt plays AnimOpen once at source rate 1 with Clamp playback and retains its endpoint.",
            ["targetAnimation"] = {
                ["bytes"] = 178922,
                ["path"] = "Units/ucs2101/LOD0/ucs2101.sananimation",
                ["sha256"] = "2fcc2b2e73215b86ddcf4a5c03c9dc8fd88558b78f8be379c8d13fbc754ffc4e",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 254977,
                ["path"] = "Units/ucs2101/LOD0/ucs2101_lod0.sanmodel",
                ["sha256"] = "2c96d2a103a9b55fce4e680cd7e83c14e8970d1d82c942c90315509ed11dd207",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 11854,
                ["path"] = "Units/ucs2101/LOD0/ucs2101.sanskeleton",
                ["sha256"] = "d7647025ab8da8f42400b8d002e64d048fc7f9f3e606c7502f1565a5133a3b85",
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
            ["sourceBlueprint"] = "units/UAB2303/UAB2303_unit.bp",
            ["sourceBlueprintSha256"] = "f056166ac1588ee419d833f890aefbf3db56798f05bfc914925c44a8dfc98bac",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ARTILLERY",
                [3] = "BUILTBYTIER2COMMANDER",
                [4] = "BUILTBYTIER2ENGINEER",
                [5] = "BUILTBYTIER3COMMANDER",
                [6] = "BUILTBYTIER3ENGINEER",
                [7] = "DRAGBUILD",
                [8] = "INDIRECTFIRE",
                [9] = "OVERLAYINDIRECTFIRE",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SIZE4",
                [14] = "SORTSTRATEGIC",
                [15] = "STRATEGIC",
                [16] = "STRUCTURE",
                [17] = "TECH2",
                [18] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB2303",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2101",
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
                            ["rackBone"] = "Turret_Recoil",
                        },
                    },
                    ["rateOfFire"] = 0.05,
                    ["reloadTime"] = 20,
                    ["sourceCategory"] = "Artillery",
                    ["sourceProjectile"] = "/projectiles/AIFMiasmaShell01/AIFMiasmaShell01_proj.bp",
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixIdlePitch"] = {
            ["defaultPitchAdjustment"] = -30,
            ["poseResetTime"] = 3,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 1,
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
            ["y"] = 0.35,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1.2,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2200,
            ["regen"] = 0,
            ["value"] = 2200,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1980,
        ["cost"] = {
            ["alloys"] = 2772,
            ["energy"] = 19800,
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
        ["displayName"] = "Miasma",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Miasma",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucs2101",
        ["unitTypeName"] = "Miasma",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 5,
            ["outerRadius"] = 128,
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
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CHOSEN",
        [5] = "INDIRECT_FIRE",
        [6] = "STRATEGIC",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_ARTILLERY",
        [12] = "SCFA_BUILTBYTIER2COMMANDER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3COMMANDER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_INDIRECTFIRE",
        [18] = "SCFA_OVERLAYINDIRECTFIRE",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTSTRATEGIC",
        [24] = "SCFA_STRATEGIC",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH2",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2101/LOD0/ucs2101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2101/LOD0/ucs2101.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.6499999999999999,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.566,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.6859999999999999,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.854,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.83,
                    ["z"] = 0.18,
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
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 1,
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
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = -30,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 30,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 6,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 26.13,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 6,
                },
            },
            ["damage"] = 575,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
            ["effects"] = {},
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Water",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 14,
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
            ["projectileLifetime"] = 6.123230003827019,
            ["projectileTemplate"] = "psf0072",
            ["rangeMax"] = 128,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 20,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "989a1075053ba0d0c4bcea3db313b05e58a1a95f9c7dc6249a5eacbf89c209ed",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/AIFMiasmaShell01/AIFMiasmaShell01_proj.bp",
            },
            ["scoSourceCategory"] = "Artillery",
            ["scoSourceLabel"] = "MainGun",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
