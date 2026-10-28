-- ues2001: Triad
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "UEB2301 -> ues2001",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB2301/UEB2301_unit.bp",
            ["sourceBlueprintSha256"] = "97f831fed87fef94266593852b044fd26b7b09e2066b494b0c6bb15aa93d67b9",
            ["sourcePrimaryWeapon"] = "TDFGauss02",
            ["sourceScript"] = "units/UEB2301/UEB2301_Script.lua",
            ["sourceScriptSha256"] = "0d73fab7b3e01e0e07dd665acef30de28019210633ac29aa5ad0dbb667146d8c",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.51,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.68,
                ["y"] = 1.67,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.53,
            ["y"] = 1.52,
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
            ["y"] = 0.51,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.45,
            ["y"] = 1.17,
            ["z"] = 1.44,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2250,
            ["regen"] = 0,
            ["value"] = 2250,
        },
    },
    ["economy"] = {
        ["buildTime"] = 450,
        ["cost"] = {
            ["alloys"] = 540,
            ["energy"] = 3600,
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
        ["displayName"] = "Triad",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Triad",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 1058.9,
            ["WaterSurface"] = 1626.2,
        },
        ["tpId"] = "ues2001",
        ["unitTypeName"] = "EDAT2PointDefence",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 50,
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
        [1] = "ANTI_SURFACE",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "DEFENCE",
        [5] = "DIRECT_FIRE",
        [6] = "EDA",
        [7] = "LAND",
        [8] = "STRUCTURE",
        [9] = "TECH2",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_DEFENSE",
        [16] = "SCFA_DIRECTFIRE",
        [17] = "SCFA_DRAGBUILD",
        [18] = "SCFA_OVERLAYDIRECTFIRE",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTDEFENSE",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_UEF",
        [27] = "SCFA_VISIBLETORECON",
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
                    ["particleName"] = "VFX/Death/ved2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.261,
                    ["y"] = 0.8025,
                    ["z"] = -0.288,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.319,
                    ["y"] = 0.7206,
                    ["z"] = 0.2592,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.29,
                    ["y"] = 0.8376,
                    ["z"] = 0.2304,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.261,
                    ["y"] = 1.0013999999999998,
                    ["z"] = -0.288,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.319,
                    ["y"] = 0.978,
                    ["z"] = 0.2592,
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
                ["y"] = 0.51,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.68,
                ["y"] = 1.67,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle02",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 55,
                    ["pitchMin"] = -55,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 35,
                    ["reduceMuzzleVelocityToTarget"] = false,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 65,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom5224",
                },
            },
            ["damage"] = 70,
            ["damageFriendly"] = false,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ues2001/muzzle_gauss01.sanvfx",
            },
            ["firingRandomness"] = 0.1,
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
                        [1] = "Turret_Muzzle01",
                        [2] = "Turret_Muzzle02",
                        [3] = "Turret_Muzzle03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Muzzle02",
                },
                ["Turret_Muzzle02"] = {
                    ["aimController"] = "Turret_Muzzle02",
                },
                ["Turret_Muzzle03"] = {
                    ["aimController"] = "Turret_Muzzle02",
                },
            },
            ["projectileLifetime"] = 1.6428571428571428,
            ["projectileTemplate"] = "psf0152",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadProgressBar"] = false,
            ["reloadTime"] = 1.6666666666666667,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f0b2f7b0ac0252a9ae597efaea72a9841bfe7943ac9936254837c5900a665e7d",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Gauss01",
                ["sourceProjectile"] = "/projectiles/TDFGauss02/TDFGauss02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Gauss01",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
