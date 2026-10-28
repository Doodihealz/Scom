-- ues2201: Air Cleaner
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "UEB2204 -> ues2201",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB2204/UEB2204_unit.bp",
            ["sourceBlueprintSha256"] = "8e459e3d4f2528c88597b13df611cb6999ddd113e97d83237cd1049ab0788099",
            ["sourcePrimaryWeapon"] = "TAALightFragmentationShell01",
            ["sourceScript"] = "units/UEB2204/UEB2204_script.lua",
            ["sourceScriptSha256"] = "96a7e4dc1adb2bb28ea52bcf636f4d47f7d3ac7528bbccaec5ee8bd949f7b362",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.07,
                ["z"] = -0.14,
            },
            ["size"] = {
                ["x"] = 1.25,
                ["y"] = 1.65,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.1,
            ["y"] = 1.5,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.07,
            ["z"] = -0.14,
        },
        ["collisionSize"] = {
            ["x"] = 1.02,
            ["y"] = 1.47,
            ["z"] = 1.42,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3700,
            ["regen"] = 0,
            ["value"] = 3700,
        },
    },
    ["economy"] = {
        ["buildTime"] = 700,
        ["cost"] = {
            ["alloys"] = 560,
            ["energy"] = 5600,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Air Cleaner",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "aa",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_antiAir.png",
        ["iconUIBuildSortPriority"] = 310,
        ["iconUIType"] = "amphibious",
        ["name"] = "Air Cleaner",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 804.3,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues2201",
        ["unitTypeName"] = "EDAT2AA",
    },
    ["intel"] = {
        ["visionRadius"] = 24,
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 44,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "DEFENCE",
        [5] = "EDA",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ANTIAIR",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3ENGINEER",
        [13] = "SCFA_DEFENSE",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_OVERLAYANTIAIR",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SIZE4",
        [20] = "SCFA_SORTDEFENSE",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TECH2",
        [23] = "SCFA_UEF",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18359999999999999,
                    ["y"] = 0.2975,
                    ["z"] = -0.424,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22440000000000002,
                    ["y"] = 0.1946,
                    ["z"] = 0.11559999999999998,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.20400000000000001,
                    ["y"] = 0.3416,
                    ["z"] = 0.08719999999999997,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18359999999999999,
                    ["y"] = 0.5473999999999999,
                    ["z"] = -0.424,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22440000000000002,
                    ["y"] = 0.518,
                    ["z"] = 0.11559999999999998,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 69,
            ["lod1distance"] = 179,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.07,
                ["z"] = -0.14,
            },
            ["size"] = {
                ["x"] = 1.25,
                ["y"] = 1.65,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Barrel",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 10,
                    ["pitchMin"] = -80,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 20,
                    ["reduceMuzzleVelocityToTarget"] = false,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom5225",
                },
            },
            ["damage"] = 102,
            ["damageFriendly"] = false,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ues2201/muzzle_aagun.sanvfx",
            },
            ["firingRandomness"] = 2.5,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Right",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Left",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Turret_Muzzle_Left"] = {
                    ["aimController"] = "Turret_Barrel",
                },
                ["Turret_Muzzle_Right"] = {
                    ["aimController"] = "Turret_Barrel",
                },
            },
            ["projectileLifetime"] = 3.75,
            ["projectileTemplate"] = "psf0023",
            ["rangeMax"] = 44,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.4,
            ["reloadProgressBar"] = false,
            ["reloadTime"] = 0.6666666666666666,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "40248b18e2d77e9ee0659444c440511b4232b515eff6372774d1c42b539dc588",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/TAALightFragmentationShell01/TAALightFragmentationShell01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
