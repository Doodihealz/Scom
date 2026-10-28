-- ugs1001: Auto Gun
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "URB2101 -> ugs1001",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB2101/URB2101_unit.bp",
            ["sourceBlueprintSha256"] = "65793eefd69516a503a00c9dc6fd6ec53cbf3f6b41c1aeef042fafddcc29acee",
            ["sourcePrimaryWeapon"] = "CDFLaserHeavy01",
            ["sourceScript"] = "units/URB2101/URB2101_Script.lua",
            ["sourceScriptSha256"] = "b8ab02c1335332de6de6055b4ae6193f04346af6d3660d5c6764852cd8d75c41",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.43,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.96,
                ["y"] = 1.31,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 0.81,
            ["y"] = 1.16,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.43,
            ["z"] = -0.05,
        },
        ["collisionSize"] = {
            ["x"] = 0.73,
            ["y"] = 1.01,
            ["z"] = 1.08,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1300,
            ["regen"] = 0,
            ["value"] = 1300,
        },
    },
    ["economy"] = {
        ["buildTime"] = 250,
        ["cost"] = {
            ["alloys"] = 250,
            ["energy"] = 2000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Auto Gun",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Auto Gun",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 318,
            ["WaterSurface"] = 392.6,
        },
        ["tpId"] = "ugs1001",
        ["unitTypeName"] = "GuardT1PointDefence",
    },
    ["intel"] = {
        ["visionRadius"] = 24,
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "ANTI_SURFACE",
        [2] = "BUILDABLE_BY_T1_ENGINEER",
        [3] = "BUILDABLE_BY_T2_ENGINEER",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "DEFENCE",
        [6] = "DIRECT_FIRE",
        [7] = "GUARD",
        [8] = "LAND",
        [9] = "STRUCTURE",
        [10] = "TECH1",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYCOMMANDER",
        [13] = "SCFA_BUILTBYTIER1ENGINEER",
        [14] = "SCFA_BUILTBYTIER2ENGINEER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
        [16] = "SCFA_CYBRAN",
        [17] = "SCFA_DEFENSE",
        [18] = "SCFA_DIRECTFIRE",
        [19] = "SCFA_DRAGBUILD",
        [20] = "SCFA_OVERLAYDIRECTFIRE",
        [21] = "SCFA_PRODUCTSC1",
        [22] = "SCFA_RECLAIMABLE",
        [23] = "SCFA_SELECTABLE",
        [24] = "SCFA_SIZE4",
        [25] = "SCFA_SORTDEFENSE",
        [26] = "SCFA_STRUCTURE",
        [27] = "SCFA_TECH1",
        [28] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/Death/vgd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1314,
                    ["y"] = 0.6825,
                    ["z"] = -0.266,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.1606,
                    ["y"] = 0.6118,
                    ["z"] = 0.14440000000000003,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.146,
                    ["y"] = 0.7128000000000001,
                    ["z"] = 0.1228,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1314,
                    ["y"] = 0.8542,
                    ["z"] = -0.266,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.1606,
                    ["y"] = 0.8340000000000001,
                    ["z"] = 0.14440000000000003,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 173,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.43,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.96,
                ["y"] = 1.31,
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
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 65,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 35,
                    ["reduceMuzzleVelocityToTarget"] = false,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom1114",
                },
            },
            ["damage"] = 50,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugs1001/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
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
            ["projectileLifetime"] = 2.875,
            ["projectileTemplate"] = "psf0017",
            ["rangeMax"] = 26,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadProgressBar"] = false,
            ["reloadTime"] = 0.3333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "af6d6d5a993f916fce71159d06b894d8e1269fe8621913b4064fc668f402ac6b",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/CDFLaserHeavy01/CDFLaserHeavy01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
