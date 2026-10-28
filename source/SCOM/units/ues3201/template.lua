-- ues3201: Flayer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "UEB2304 -> ues3201",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB2304/UEB2304_unit.bp",
            ["sourceBlueprintSha256"] = "6a0bfa968a2df65ad01e877ef63235e93a3e8ed66b9a2fe2a53d9bb97c7dc878",
            ["sourcePrimaryWeapon"] = "TAAMissileFlayer01",
            ["sourceScript"] = "units/UEB2304/UEB2304_script.lua",
            ["sourceScriptSha256"] = "1402433c0c128ed89356e5df501ba8dd5e710eb793587a5e1420681fc9199b4b",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.09,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.56,
                ["y"] = 1.55,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.41,
            ["y"] = 1.4,
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
            ["y"] = 0.09,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.33,
            ["y"] = 2.35,
            ["z"] = 1.32,
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Flayer",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "aa",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_antiAir.png",
        ["iconUIBuildSortPriority"] = 310,
        ["iconUIType"] = "amphibious",
        ["name"] = "Flayer",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 4158.5,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ues3201",
        ["unitTypeName"] = "EDAT3AA",
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
        [3] = "DEFENCE",
        [4] = "EDA",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_ANTIAIR",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DEFENSE",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_OVERLAYANTIAIR",
        [14] = "SCFA_PRODUCTSC1",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SIZE4",
        [18] = "SCFA_SORTDEFENSE",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH3",
        [21] = "SCFA_UEF",
        [22] = "SCFA_VISIBLETORECON",
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
                    ["x"] = 0.2394,
                    ["y"] = 0.6775,
                    ["z"] = -0.264,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2926,
                    ["y"] = 0.513,
                    ["z"] = 0.2376,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.266,
                    ["y"] = 0.7480000000000001,
                    ["z"] = 0.21120000000000003,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2394,
                    ["y"] = 1.077,
                    ["z"] = -0.264,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2926,
                    ["y"] = 1.03,
                    ["z"] = 0.2376,
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
                ["y"] = 0.09,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.56,
                ["y"] = 1.55,
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
                    ["aimTolerance"] = 10,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 55,
                    ["pitchMin"] = -105,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 30,
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
                    ["name"] = "aeom3134",
                },
            },
            ["damage"] = 200,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ues3201/muzzle_missilerack01.sanvfx",
            },
            ["firingRandomness"] = 0,
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
                        [1] = "Turret_Muzzle_Left01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Right01",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Left02",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Right02",
                    },
                },
                [5] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Left03",
                    },
                },
                [6] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_Right03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.2,
            ["muzzleSalvoSize"] = 6,
            ["muzzles"] = {
                ["Turret_Muzzle_Left01"] = {
                    ["aimController"] = "Turret_Barrel",
                },
                ["Turret_Muzzle_Left02"] = {
                    ["aimController"] = "Turret_Barrel",
                },
                ["Turret_Muzzle_Left03"] = {
                    ["aimController"] = "Turret_Barrel",
                },
                ["Turret_Muzzle_Right01"] = {
                    ["aimController"] = "Turret_Barrel",
                },
                ["Turret_Muzzle_Right02"] = {
                    ["aimController"] = "Turret_Barrel",
                },
                ["Turret_Muzzle_Right03"] = {
                    ["aimController"] = "Turret_Barrel",
                },
            },
            ["projectileLifetime"] = 6,
            ["projectileTemplate"] = "psf0024",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.4,
            ["reloadProgressBar"] = false,
            ["reloadTime"] = 3.571428571428571,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "8b0ec153e08f756d7623a671a2dcc2852bd3b54ca1e2a23af4cf83e81f5d6fc9",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack01",
                ["sourceProjectile"] = "/projectiles/TAAMissileFlayer01/TAAMissileFlayer01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack01",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
