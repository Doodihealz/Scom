-- uss2201: Sinnatha
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.225,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.55,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 2,
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
            ["y"] = 0.225,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 1.55,
            ["z"] = 0.8,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3600,
            ["regen"] = 0,
            ["value"] = 3600,
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Sinnatha",
        ["faDualWaterPlacement"] = true,
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "aa",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_antiAir.png",
        ["iconUIBuildSortPriority"] = 310,
        ["iconUIType"] = "amphibious",
        ["name"] = "Sinnatha",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 1061.1,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uss2201",
        ["unitTypeName"] = "UnknownT2AA",
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
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_ANTIAIR",
        [7] = "SCFA_BUILTBYTIER2COMMANDER",
        [8] = "SCFA_BUILTBYTIER2ENGINEER",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DEFENSE",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_OVERLAYANTIAIR",
        [14] = "SCFA_PRODUCTFA",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SERAPHIM",
        [18] = "SCFA_SIZE4",
        [19] = "SCFA_SORTDEFENSE",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH2",
        [22] = "SCFA_VISIBLETORECON",
        [23] = "SERAPHIM",
        [24] = "STRUCTURE",
        [25] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2201/LOD0/uss2201.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2201/LOD0/uss2201.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.6125,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.504,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.659,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.876,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.8450000000000001,
                    ["z"] = 0.144,
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
                ["y"] = 0.225,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.55,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "WepFocus",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Barrel_Right",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 20,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 20,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom1124",
                },
            },
            ["damage"] = 53,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uss2201/muzzle_aafizz.sanvfx",
            },
            ["firingRandomness"] = 2,
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
                        [1] = "Turret_Left_Muzzle",
                        [2] = "Turret_Right_Muzzle",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Left_Muzzle"] = {
                    ["aimController"] = "WepFocus",
                },
                ["Turret_Right_Muzzle"] = {
                    ["aimController"] = "WepFocus",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0108",
            ["rangeMax"] = 44,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.8,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "2143068adec9f3f97c804255fb5b2534e53d693eb44a9a2b99d0110b88c4ecb1",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAFizz",
                ["sourceProjectile"] = "/projectiles/SAAOlarisAAArtillery06/SAAOlarisAAArtillery06_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAFizz",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
