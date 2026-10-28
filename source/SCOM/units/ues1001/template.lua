-- ues1001: DM1 Plasma Cannon
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "UEB2101 -> ues1001",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB2101/UEB2101_unit.bp",
            ["sourceBlueprintSha256"] = "96819759123b21cac02aea99aaf5ceee1821801b3d0d6041d8811d1e4f8e01c5",
            ["sourcePrimaryWeapon"] = "TDFPlasma01",
            ["sourceScript"] = "units/UEB2101/UEB2101_Script.lua",
            ["sourceScriptSha256"] = "d238a8e19ad7a8d06d47e8814d20f159962c5bb3f1964be193926b72cad72339",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.42,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.33,
                ["y"] = 1.33,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.18,
            ["y"] = 1.18,
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
            ["y"] = 0.42,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.1,
            ["y"] = 0.98,
            ["z"] = 1.1,
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
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "DM1 Plasma Cannon",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "DM1 Plasma Cannon",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 318,
            ["WaterSurface"] = 391.7,
        },
        ["tpId"] = "ues1001",
        ["unitTypeName"] = "EDAT1PointDefence",
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
        [7] = "EDA",
        [8] = "LAND",
        [9] = "STRUCTURE",
        [10] = "TECH1",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYCOMMANDER",
        [13] = "SCFA_BUILTBYTIER1ENGINEER",
        [14] = "SCFA_BUILTBYTIER2ENGINEER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
        [16] = "SCFA_DEFENSE",
        [17] = "SCFA_DIRECTFIRE",
        [18] = "SCFA_DRAGBUILD",
        [19] = "SCFA_OVERLAYDIRECTFIRE",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SIZE4",
        [24] = "SCFA_SORTDEFENSE",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH1",
        [27] = "SCFA_UEF",
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
                    ["particleName"] = "VFX/Death/ved2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.198,
                    ["y"] = 0.665,
                    ["z"] = -0.22000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24200000000000002,
                    ["y"] = 0.5964,
                    ["z"] = 0.198,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.22000000000000003,
                    ["y"] = 0.6944,
                    ["z"] = 0.17600000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.198,
                    ["y"] = 0.8315999999999999,
                    ["z"] = -0.22000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24200000000000002,
                    ["y"] = 0.812,
                    ["z"] = 0.198,
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
                ["y"] = 0.42,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.33,
                ["y"] = 1.33,
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
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -60,
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
                    ["name"] = "aeom3114",
                },
            },
            ["damage"] = 50,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ues1001/muzzle_maingun.sanvfx",
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
            ["projectileTemplate"] = "psf0157",
            ["rangeMax"] = 26,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadProgressBar"] = false,
            ["reloadTime"] = 0.3333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "cd2fa28e058af6a39e8ca4ef7e440b5c655fad3f899cf06cea0eb20d70586103",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/TDFPlasma01/TDFPlasma01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
