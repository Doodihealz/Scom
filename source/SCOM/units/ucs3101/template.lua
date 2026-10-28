-- ucs3101: Emissary
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
                    ["visionRadius"] = 28,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 5,
                    ["z"] = 5,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 8,
                    ["sizeZ"] = 8,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB2302/UAB2302_unit.bp",
            ["sourceBlueprintSha256"] = "8c8e58b4ea9a3b74aded12e3db0276383fe8b4db6adc2d92c703dd6bf8074999",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "ARTILLERY",
                [3] = "BUILTBYTIER3COMMANDER",
                [4] = "BUILTBYTIER3ENGINEER",
                [5] = "DRAGBUILD",
                [6] = "INDIRECTFIRE",
                [7] = "OVERLAYINDIRECTFIRE",
                [8] = "PRODUCTSC1",
                [9] = "RECLAIMABLE",
                [10] = "SELECTABLE",
                [11] = "SHOWATTACKRETICLE",
                [12] = "SIZE16",
                [13] = "SORTSTRATEGIC",
                [14] = "STRATEGIC",
                [15] = "STRUCTURE",
                [16] = "TECH3",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB2302",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3101",
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
                            ["rackBone"] = "Turret_B01",
                        },
                    },
                    ["rateOfFire"] = 0.05,
                    ["reloadTime"] = 20,
                    ["sourceCategory"] = "Artillery",
                    ["sourceProjectile"] = "/projectiles/AIFSonanceShell02/AIFSonanceShell02_proj.bp",
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixEmissaryArtillery"] = {
            ["creativeSpawnStartsReady"] = true,
            ["pitchMax"] = 85,
            ["projectileSpeed"] = 67,
            ["rangeMax"] = 900,
            ["rangeMin"] = 150,
            ["version"] = "1.0.0",
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.4,
                ["y"] = 3.4,
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
            ["y"] = 1.75,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3.5,
            ["y"] = 4,
            ["z"] = 3.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 12000,
            ["regen"] = 0,
            ["value"] = 12000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 30500,
        ["cost"] = {
            ["alloys"] = 91500,
            ["energy"] = 915000,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Emissary",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Emissary",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ucs3101",
        ["unitTypeName"] = "Emissary",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 150,
            ["outerRadius"] = 900,
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
        ["x"] = 8,
        ["y"] = 8,
    },
    ["tags"] = {
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CHOSEN",
        [4] = "INDIRECT_FIRE",
        [5] = "STRATEGIC",
        [6] = "STRUCTURE",
        [7] = "TECH3",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ARTILLERY",
        [11] = "SCFA_BUILTBYTIER3COMMANDER",
        [12] = "SCFA_BUILTBYTIER3ENGINEER",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_INDIRECTFIRE",
        [15] = "SCFA_OVERLAYINDIRECTFIRE",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SHOWATTACKRETICLE",
        [20] = "SCFA_SIZE16",
        [21] = "SCFA_SORTSTRATEGIC",
        [22] = "SCFA_STRATEGIC",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH3",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3101/LOD0/ucs3101.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 2.75,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 2.4699999999999998,
                    ["z"] = 0.63,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.7000000000000001,
                    ["y"] = 2.87,
                    ["z"] = 0.56,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 3.4299999999999997,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 3.35,
                    ["z"] = 0.63,
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
                ["y"] = 1.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3.4,
                ["y"] = 3.4,
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
                    ["pitchBone"] = "Turret_B01",
                    ["pitchMax"] = 85,
                    ["pitchMin"] = -15,
                    ["pitchSpeed"] = 3,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 65,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 3,
                },
            },
            ["damage"] = 6000,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ucs3101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0.75,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Water",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
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
            ["projectileLifetime"] = 120,
            ["projectileTemplate"] = "psf0078",
            ["rangeMax"] = 900,
            ["rangeMin"] = 150,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 20,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "c7c0ced51e50b08e6ef4feceff0e6e60e09bc1ad6e1410f728230adb95b3693f",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/AIFSonanceShell02/AIFSonanceShell02_proj.bp",
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
