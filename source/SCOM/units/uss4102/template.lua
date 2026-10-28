-- uss4102: Yolona Oss
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint",
        },
        ["scoSourceInterception"] = {
            ["silo"] = {
                ["autoIntercept"] = false,
                ["buildPower"] = 2160,
                ["buildTime"] = 129600,
                ["charge"] = 5,
                ["cost"] = {
                    ["alloys"] = 600,
                    ["energy"] = 6000,
                },
                ["cycleReload"] = 0,
                ["damage"] = 0,
                ["damageRadius"] = 0,
                ["deployDuration"] = 0,
                ["deployKey"] = "sco_source_launch",
                ["deployRate"] = 10,
                ["initialAmmo"] = 0,
                ["maxAmmo"] = 1,
                ["muzzleVelocity"] = 0,
                ["muzzles"] = {
                    [1] = "Attachpoint",
                },
                ["nukeRings"] = {
                    [1] = {
                        ["damage"] = 1000001,
                        ["radius"] = 45,
                        ["ticks"] = 24,
                        ["totalTime"] = 12,
                    },
                    [2] = {
                        ["damage"] = 7500,
                        ["radius"] = 60,
                        ["ticks"] = 20,
                        ["totalTime"] = 5,
                    },
                },
                ["preserveAttack"] = false,
                ["projectile"] = "psf0136",
                ["rangeMax"] = 20000,
                ["rangeMin"] = 0,
                ["reload"] = 1,
                ["repackTimeout"] = 32.5,
                ["role"] = "launcher",
                ["sourceId"] = "XSB2401",
                ["sourceLabel"] = "ExperimentalNuke",
                ["sourceStockpile"] = true,
                ["version"] = "1.0.0",
            },
            ["sourceId"] = "XSB2401",
            ["targetId"] = "uss4102",
            ["weapons"] = {
                ["ExperimentalNuke"] = {
                    ["counted"] = true,
                    ["damage"] = 0,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 0,
                    ["muzzles"] = {
                        [1] = "Attachpoint",
                    },
                    ["projectile"] = "psf0136",
                    ["rangeMax"] = 20000,
                    ["rangeMin"] = 0,
                    ["reload"] = 1,
                    ["sourceIndex"] = 1,
                    ["sourceLabel"] = "ExperimentalNuke",
                },
            },
        },
        ["scoTactical"] = {
            ["autoIntercept"] = false,
            ["buildPower"] = 2160,
            ["buildTime"] = 129600,
            ["charge"] = 5,
            ["cost"] = {
                ["alloys"] = 600,
                ["energy"] = 6000,
            },
            ["cycleReload"] = 0,
            ["damage"] = 0,
            ["damageRadius"] = 0,
            ["deployDuration"] = 0,
            ["deployKey"] = "sco_source_launch",
            ["deployRate"] = 10,
            ["initialAmmo"] = 0,
            ["maxAmmo"] = 1,
            ["muzzleVelocity"] = 0,
            ["muzzles"] = {
                [1] = "Attachpoint",
            },
            ["nukeRings"] = {
                [1] = {
                    ["damage"] = 1000001,
                    ["radius"] = 45,
                    ["ticks"] = 24,
                    ["totalTime"] = 12,
                },
                [2] = {
                    ["damage"] = 7500,
                    ["radius"] = 60,
                    ["ticks"] = 20,
                    ["totalTime"] = 5,
                },
            },
            ["preserveAttack"] = false,
            ["projectile"] = "psf0136",
            ["rangeMax"] = 20000,
            ["rangeMin"] = 0,
            ["reload"] = 1,
            ["repackTimeout"] = 32.5,
            ["role"] = "launcher",
            ["sourceId"] = "XSB2401",
            ["sourceLabel"] = "ExperimentalNuke",
            ["sourceStockpile"] = true,
            ["version"] = "1.0.0",
        },
        ["scoYolonaMissile"] = {
            ["bone"] = "Nuke",
            ["lift"] = 6.555,
            ["position"] = {
                ["x"] = 0.03510554122913923,
                ["y"] = -4.9710147399902365,
                ["z"] = 5.866009745152829e-07,
            },
            ["projectileOrigin"] = {
                ["x"] = -6.436675434625372e-10,
                ["y"] = -3.855591734492862e-07,
                ["z"] = 2.3970380452224234,
            },
            ["root"] = "Root",
            ["rotation"] = {
                ["w"] = 0.7071066968928154,
                ["x"] = -0.7071068654802295,
                ["y"] = 1.6858740158000525e-07,
                ["z"] = 1.6858738650711404e-07,
            },
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.55,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 3,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 4.666666507720947,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.55,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2,
            ["y"] = 1.6,
            ["z"] = 2,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Attachpoint",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
        },
        ["buildPower"] = 2160,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 12000,
            ["regen"] = 0,
            ["value"] = 12000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 125100,
        ["cost"] = {
            ["alloys"] = 250200,
            ["energy"] = 10008000,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Yolona Oss",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "indirect",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_experimental1_indirect.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Yolona Oss",
        ["orders"] = {
            ["ManualFire1"] = true,
            ["ManualFire2"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "uss4102",
        ["unitTypeName"] = "UnknownT4StrategicLauncher",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20000,
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
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "SCFA_ALLUNITS",
        [3] = "SCFA_BUILTBYTIER3COMMANDER",
        [4] = "SCFA_BUILTBYTIER3ENGINEER",
        [5] = "SCFA_DRAGBUILD",
        [6] = "SCFA_EXPERIMENTAL",
        [7] = "SCFA_NUKE",
        [8] = "SCFA_PRODUCTFA",
        [9] = "SCFA_RECLAIMABLE",
        [10] = "SCFA_SELECTABLE",
        [11] = "SCFA_SERAPHIM",
        [12] = "SCFA_SILO",
        [13] = "SCFA_SIZE12",
        [14] = "SCFA_SORTSTRATEGIC",
        [15] = "SCFA_STRATEGIC",
        [16] = "SCFA_STRUCTURE",
        [17] = "SCFA_VISIBLETORECON",
        [18] = "SERAPHIM",
        [19] = "STRATEGIC",
        [20] = "STRUCTURE",
        [21] = "TECH4",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss4102/LOD0/uss4102.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss4102/LOD0/uss4102.sananimation",
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
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.9500000000000001,
                    ["z"] = -0.4,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 0.8380000000000001,
                    ["z"] = 0.36,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.4,
                    ["y"] = 0.9980000000000001,
                    ["z"] = 0.32,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.36,
                    ["y"] = 1.222,
                    ["z"] = -0.4,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.44,
                    ["y"] = 1.1900000000000002,
                    ["z"] = 0.36,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 193,
            ["lod1distance"] = 504,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.55,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 3,
                ["y"] = 3,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Attachpoint",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Attachpoint",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 1,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Attachpoint",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 1,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uss4102/muzzle_experimentalnuke.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Attachpoint",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Attachpoint"] = {
                    ["aimController"] = "Attachpoint",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0136",
            ["rangeMax"] = 20000,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "45b2da53faeb578726fb3ff93c32dc1b4bbaac96d3f0ed3e52194d25542b2b7c",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ExperimentalNuke",
                ["sourceProjectile"] = "/projectiles/SIFExperimentalStrategicMissile01/SIFExperimentalStrategicMissile01_proj.bp",
            },
            ["scoSourceInterceptionLabel"] = "ExperimentalNuke",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "ExperimentalNuke",
            },
            ["scoTacticalOwned"] = true,
            ["targetWaterLimits"] = "Above",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoTactical"] = UnitTemplate["additions"]["scoSourceInterception"]["silo"]
