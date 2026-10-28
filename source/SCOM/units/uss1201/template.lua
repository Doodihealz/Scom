-- uss1201: Ialla
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.35,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1.6666666269302368,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
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
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 1,
            ["z"] = 0.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1200,
            ["regen"] = 0,
            ["value"] = 1200,
        },
    },
    ["economy"] = {
        ["buildTime"] = 250,
        ["cost"] = {
            ["alloys"] = 200,
            ["energy"] = 2000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Ialla",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "aa",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_antiAir.png",
        ["iconUIBuildSortPriority"] = 310,
        ["iconUIType"] = "amphibious",
        ["name"] = "Ialla",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 413,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uss1201",
        ["unitTypeName"] = "UnknownT1AA",
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T1_ENGINEER",
        [3] = "BUILDABLE_BY_T2_ENGINEER",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "DEFENCE",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_ANTIAIR",
        [8] = "SCFA_BUILTBYCOMMANDER",
        [9] = "SCFA_BUILTBYTIER1ENGINEER",
        [10] = "SCFA_BUILTBYTIER2ENGINEER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DEFENSE",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_OVERLAYANTIAIR",
        [15] = "SCFA_PRODUCTFA",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SERAPHIM",
        [19] = "SCFA_SIZE4",
        [20] = "SCFA_SORTDEFENSE",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TECH1",
        [23] = "SCFA_VISIBLETORECON",
        [24] = "SERAPHIM",
        [25] = "STRUCTURE",
        [26] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1201/LOD0/uss1201.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1201/LOD0/uss1201.sananimation",
            },
        },
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
                    ["particleName"] = "VFX/Death/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.5,
                    ["z"] = -0.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.43,
                    ["z"] = 0.09,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.53,
                    ["z"] = 0.08,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.6699999999999999,
                    ["z"] = -0.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.65,
                    ["z"] = 0.09,
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
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.35,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Aiming_Bone",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 45,
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
                    ["name"] = "acom1114",
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uss1201/muzzle_aagun.sanvfx",
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
                        [1] = "Turret_Muzzle01",
                        [2] = "Turret_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Aiming_Bone",
                },
                ["Turret_Muzzle02"] = {
                    ["aimController"] = "Turret_Aiming_Bone",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0110",
            ["rangeMax"] = 44,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.285714285714286,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "9539620fea362f051a424ba168d0bb2efc9887e1a522037fd2a7f579f0a7c3c6",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/SAAShleoAAGatlingGun02/SAAShleoAAGatlingGun02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
