-- uss3402: Ythisioz
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoSourceInterception"] = {
            ["permanentOpen"] = {
                ["animation"] = {
                    ["clipName"] = "AnimOpen",
                    ["playbackMode"] = 0,
                    ["sanAnimationPath"] = "Units/uss3402/LOD0/uss3402.sananimation",
                },
                ["duration"] = 1.100000023841858,
                ["key"] = "sco_source_permanent",
            },
            ["silo"] = {
                ["autoIntercept"] = true,
                ["buildPower"] = 1080,
                ["buildTime"] = 259200,
                ["charge"] = 0,
                ["cost"] = {
                    ["alloys"] = 3600,
                    ["energy"] = 360000,
                },
                ["cycleReload"] = 0,
                ["damage"] = 30,
                ["damageRadius"] = 0,
                ["deployDuration"] = 0,
                ["deployKey"] = "sco_source_launch",
                ["deployRate"] = 1,
                ["initialAmmo"] = 0,
                ["maxAmmo"] = 7,
                ["muzzleVelocity"] = 90,
                ["muzzles"] = {
                    [1] = "Missile_Attachpoint",
                },
                ["nukeRings"] = {},
                ["preserveAttack"] = false,
                ["projectile"] = "psf0137",
                ["rangeMax"] = 90,
                ["rangeMin"] = 0,
                ["reload"] = 1.6666666666666667,
                ["repackTimeout"] = 0,
                ["role"] = "launcher",
                ["sourceId"] = "XSB4302",
                ["sourceLabel"] = "MissileRack",
                ["sourceStockpile"] = true,
                ["version"] = "1.0.0",
            },
            ["sourceId"] = "XSB4302",
            ["targetId"] = "uss3402",
            ["weapons"] = {
                ["MissileRack"] = {
                    ["counted"] = true,
                    ["damage"] = 30,
                    ["interval"] = 0.1,
                    ["muzzleVelocity"] = 90,
                    ["muzzles"] = {
                        [1] = "Missile_Attachpoint",
                    },
                    ["projectile"] = "psf0137",
                    ["rangeMax"] = 90,
                    ["rangeMin"] = 0,
                    ["reload"] = 1.6666666666666667,
                    ["sourceIndex"] = 1,
                    ["sourceLabel"] = "MissileRack",
                    ["targetClass"] = "strategic",
                },
            },
        },
        ["scoTactical"] = {
            ["autoIntercept"] = true,
            ["buildPower"] = 1080,
            ["buildTime"] = 259200,
            ["charge"] = 0,
            ["cost"] = {
                ["alloys"] = 3600,
                ["energy"] = 360000,
            },
            ["cycleReload"] = 0,
            ["damage"] = 30,
            ["damageRadius"] = 0,
            ["deployDuration"] = 0,
            ["deployKey"] = "sco_source_launch",
            ["deployRate"] = 1,
            ["initialAmmo"] = 0,
            ["maxAmmo"] = 7,
            ["muzzleVelocity"] = 90,
            ["muzzles"] = {
                [1] = "Missile_Attachpoint",
            },
            ["nukeRings"] = {},
            ["preserveAttack"] = false,
            ["projectile"] = "psf0137",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["reload"] = 1.6666666666666667,
            ["repackTimeout"] = 0,
            ["role"] = "launcher",
            ["sourceId"] = "XSB4302",
            ["sourceLabel"] = "MissileRack",
            ["sourceStockpile"] = true,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.25,
                ["y"] = 1.25,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.5,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.5,
            ["y"] = 1.5,
            ["z"] = 1.75,
        },
    },
    ["construction"] = {
        ["buildPower"] = 1080,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3800,
            ["regen"] = 0,
            ["value"] = 3800,
        },
    },
    ["economy"] = {
        ["buildTime"] = 4500,
        ["cost"] = {
            ["alloys"] = 7500,
            ["energy"] = 105000,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Ythisioz",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Ythisioz",
        ["orders"] = {
            ["ManualFire1"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "uss3402",
        ["unitTypeName"] = "UnknownT3StrategicDefense",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 90,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["skirtSize"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["tags"] = {
        [1] = "ANTI_PROJECTILE",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "DEFENCE",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_ANTIMISSILE",
        [6] = "SCFA_BUILTBYTIER3COMMANDER",
        [7] = "SCFA_BUILTBYTIER3ENGINEER",
        [8] = "SCFA_DEFENSE",
        [9] = "SCFA_DRAGBUILD",
        [10] = "SCFA_OVERLAYDEFENSE",
        [11] = "SCFA_PRODUCTFA",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SERAPHIM",
        [15] = "SCFA_SILO",
        [16] = "SCFA_SIZE8",
        [17] = "SCFA_SORTDEFENSE",
        [18] = "SCFA_STRUCTURE",
        [19] = "SCFA_TECH3",
        [20] = "SCFA_VISIBLETORECON",
        [21] = "SERAPHIM",
        [22] = "STRUCTURE",
        [23] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["sco_source_permanent"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3402/LOD0/uss3402.sananimation",
            },
            ["source_rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3402/LOD0/uss3402.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3402/LOD0/uss3402.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 0.875,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.77,
                    ["z"] = 0.315,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30000000000000004,
                    ["y"] = 0.92,
                    ["z"] = 0.28,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 1.13,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 1.1,
                    ["z"] = 0.315,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 78,
            ["lod1distance"] = 203,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.25,
                ["y"] = 1.25,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Missile_Attachpoint",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Missile_Attachpoint",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 90,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Missile_Attachpoint",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 30,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm1101_cannon_plasma_small_muzzle.sanvfx",
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
                        [1] = "Missile_Attachpoint",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Missile_Attachpoint"] = {
                    ["aimController"] = "Missile_Attachpoint",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0137",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1.66666666666667,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "a309f59a614da7d823a027590852dda8d7b69699bc078af7a4077dd02be582b9",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack",
                ["sourceProjectile"] = "/projectiles/SIFHuAntiNuke01/SIFHuAntiNuke01_proj.bp",
            },
            ["scoSourceInterceptionLabel"] = "MissileRack",
            ["scoTacticalOwned"] = true,
            ["targetWaterLimits"] = "Above",
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoTactical"] = UnitTemplate["additions"]["scoSourceInterception"]["silo"]
UnitTemplate["visuals"]["animations"]["sco_source_permanent"] = UnitTemplate["additions"]["scoSourceInterception"]["permanentOpen"]["animation"]
