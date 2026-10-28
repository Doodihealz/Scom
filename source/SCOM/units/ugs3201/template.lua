-- ugs3201: Myrmidon
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "URB2304 -> ugs3201",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB2304/URB2304_unit.bp",
            ["sourceBlueprintSha256"] = "1d9170532ed36fa790a5cd50931ad1888e50b039091ec5590d4aa74c2ff23b64",
            ["sourcePrimaryWeapon"] = "CAAMissileNanite02",
            ["sourceScript"] = "units/URB2304/URB2304_script.lua",
            ["sourceScriptSha256"] = "e734a52d2acd547499ea1ea351e0137a1ec59a7861c2c828be15aa0e3044b0ad",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.28,
                ["z"] = -0.02,
            },
            ["size"] = {
                ["x"] = 1.46,
                ["y"] = 1.35,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.31,
            ["y"] = 1.2,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.28,
            ["z"] = -0.02,
        },
        ["collisionSize"] = {
            ["x"] = 1.23,
            ["y"] = 2.15,
            ["z"] = 1.12,
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Myrmidon",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "aa",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_antiAir.png",
        ["iconUIBuildSortPriority"] = 310,
        ["iconUIType"] = "amphibious",
        ["name"] = "Myrmidon",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 1861.9,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ugs3201",
        ["unitTypeName"] = "GuardT3AA",
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
        [4] = "GUARD",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_ANTIAIR",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_CYBRAN",
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
                    ["particleName"] = "VFX/Death/vgd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.22139999999999999,
                    ["y"] = 0.8175,
                    ["z"] = -0.24400000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2706,
                    ["y"] = 0.667,
                    ["z"] = 0.1816,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.246,
                    ["y"] = 0.882,
                    ["z"] = 0.15920000000000004,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.22139999999999999,
                    ["y"] = 1.1829999999999998,
                    ["z"] = -0.24400000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2706,
                    ["y"] = 1.1400000000000001,
                    ["z"] = 0.1816,
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
                ["y"] = 0.28,
                ["z"] = -0.02,
            },
            ["size"] = {
                ["x"] = 1.46,
                ["y"] = 1.35,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Left_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 50,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 75,
                    ["pitchMin"] = -25,
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
                    ["name"] = "agom3134",
                },
            },
            ["damage"] = 300,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugs3201/muzzle_missile01.sanvfx",
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
                        [1] = "Turret_Left_Muzzle01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Left_Muzzle02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Turret_Left_Muzzle03",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Turret_Left_Muzzle04",
                    },
                },
                [5] = {
                    ["muzzles"] = {
                        [1] = "Turret_Right_Muzzle01",
                    },
                },
                [6] = {
                    ["muzzles"] = {
                        [1] = "Turret_Right_Muzzle02",
                    },
                },
                [7] = {
                    ["muzzles"] = {
                        [1] = "Turret_Right_Muzzle03",
                    },
                },
                [8] = {
                    ["muzzles"] = {
                        [1] = "Turret_Right_Muzzle04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.3,
            ["muzzleSalvoSize"] = 4,
            ["muzzles"] = {
                ["Turret_Left_Muzzle01"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
                ["Turret_Left_Muzzle02"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
                ["Turret_Left_Muzzle03"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
                ["Turret_Left_Muzzle04"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
                ["Turret_Right_Muzzle01"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
                ["Turret_Right_Muzzle02"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
                ["Turret_Right_Muzzle03"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
                ["Turret_Right_Muzzle04"] = {
                    ["aimController"] = "Turret_Left_Muzzle01",
                },
            },
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "psf0006",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.4,
            ["reloadProgressBar"] = false,
            ["reloadTime"] = 3.571428571428571,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "927a795462a0c10f7baa08aef672414b47b04a96236672be24d6a4a03ba0a935",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Missile01",
                ["sourceProjectile"] = "/projectiles/CAAMissileNanite02/CAAMissileNanite02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Missile01",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
