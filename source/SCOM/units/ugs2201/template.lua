-- ugs2201: Burst Master
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "URB2204 -> ugs2201",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB2204/URB2204_unit.bp",
            ["sourceBlueprintSha256"] = "6794c891d2df57fb0f930c046bcbf88a229b29f057277eb1b0bb0504e4688499",
            ["sourcePrimaryWeapon"] = "CAABurstCloud01",
            ["sourceScript"] = "units/URB2204/URB2204_script.lua",
            ["sourceScriptSha256"] = "cb85591748575c17f1e7472859d103b15a6b532eaf1084d70987fcece9430cc9",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.09,
                ["z"] = 0.05,
            },
            ["size"] = {
                ["x"] = 1.46,
                ["y"] = 1.73,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.31,
            ["y"] = 1.58,
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
            ["y"] = 0.09,
            ["z"] = 0.05,
        },
        ["collisionSize"] = {
            ["x"] = 1.23,
            ["y"] = 1.85,
            ["z"] = 1.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3400,
            ["regen"] = 0,
            ["value"] = 3400,
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
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Burst Master",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "aa",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_antiAir.png",
        ["iconUIBuildSortPriority"] = 310,
        ["iconUIType"] = "amphibious",
        ["name"] = "Burst Master",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 1221.8,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ugs2201",
        ["unitTypeName"] = "GuardT2AA",
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
        [5] = "GUARD",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ANTIAIR",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_CYBRAN",
        [15] = "SCFA_DEFENSE",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_OVERLAYANTIAIR",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SIZE4",
        [22] = "SCFA_SORTDEFENSE",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_VISIBLETORECON",
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
                    ["y"] = 0.5525,
                    ["z"] = -0.25000000000000006,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2706,
                    ["y"] = 0.42300000000000004,
                    ["z"] = 0.32,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.246,
                    ["y"] = 0.6080000000000001,
                    ["z"] = 0.29,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.22139999999999999,
                    ["y"] = 0.867,
                    ["z"] = -0.25000000000000006,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.2706,
                    ["y"] = 0.8300000000000001,
                    ["z"] = 0.32,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 182,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.09,
                ["z"] = 0.05,
            },
            ["size"] = {
                ["x"] = 1.46,
                ["y"] = 1.73,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Recoil01_Muzzle01",
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
                    ["pitchMax"] = 75,
                    ["pitchMin"] = -5,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
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
                    ["name"] = "agom1125",
                },
            },
            ["damage"] = 38,
            ["damageFriendly"] = false,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugs2201/muzzle_aagun.sanvfx",
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
                        [1] = "Turret_Recoil01_Muzzle01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Recoil01_Muzzle02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Turret_Recoil02_Muzzle01",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Turret_Recoil02_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Turret_Recoil01_Muzzle01"] = {
                    ["aimController"] = "Turret_Recoil01_Muzzle01",
                },
                ["Turret_Recoil01_Muzzle02"] = {
                    ["aimController"] = "Turret_Recoil01_Muzzle01",
                },
                ["Turret_Recoil02_Muzzle01"] = {
                    ["aimController"] = "Turret_Recoil01_Muzzle01",
                },
                ["Turret_Recoil02_Muzzle02"] = {
                    ["aimController"] = "Turret_Recoil01_Muzzle01",
                },
            },
            ["projectileLifetime"] = 5,
            ["projectileTemplate"] = "psf0081",
            ["rangeMax"] = 44,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.4,
            ["reloadProgressBar"] = false,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/CAABurstCloud01/CAABurstCloud01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
