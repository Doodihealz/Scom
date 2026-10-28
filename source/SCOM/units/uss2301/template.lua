-- uss2301: Uosthu
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoSourceInterception"] = {
            ["sourceId"] = "XSB2205",
            ["targetId"] = "uss2301",
            ["weapons"] = {
                ["AjelluTorpedoDefense"] = {
                    ["counted"] = false,
                    ["damage"] = 2,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 80,
                    ["muzzles"] = {
                        [1] = "Muzzle04",
                    },
                    ["projectile"] = "psf0114",
                    ["rangeMax"] = 32,
                    ["rangeMin"] = 0,
                    ["reload"] = 2,
                    ["sourceIndex"] = 2,
                    ["sourceLabel"] = "AjelluTorpedoDefense",
                    ["targetClass"] = "torpedo",
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.1,
                ["y"] = 1.3,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 8.333333015441895,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
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
            ["y"] = 0.1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.5,
            ["y"] = 2.2,
            ["z"] = 1.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4800,
            ["regen"] = 0,
            ["value"] = 4800,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1200,
        ["cost"] = {
            ["alloys"] = 1080,
            ["energy"] = 9000,
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
        ["displayName"] = "Uosthu",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "antiNaval",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_antiNaval.png",
        ["iconUIBuildSortPriority"] = 310,
        ["iconUIType"] = "water",
        ["name"] = "Uosthu",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {},
        ["tpId"] = "uss2301",
        ["unitTypeName"] = "UnknownT2TorpedoLauncher",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
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
        [1] = "ANTI_NAVAL",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "DEFENCE",
        [5] = "NAVAL",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_ANTINAVY",
        [8] = "SCFA_BUILTBYTIER2COMMANDER",
        [9] = "SCFA_BUILTBYTIER2ENGINEER",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DEFENSE",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_OVERLAYANTINAVY",
        [15] = "SCFA_OVERLAYDEFENSE",
        [16] = "SCFA_OVERLAYSONAR",
        [17] = "SCFA_PRODUCTFA",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SERAPHIM",
        [21] = "SCFA_SIZE4",
        [22] = "SCFA_SORTDEFENSE",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_VISIBLETORECON",
        [26] = "SERAPHIM",
        [27] = "STRUCTURE",
        [28] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2301/LOD0/uss2301.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2301/LOD0/uss2301.sananimation",
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
                    ["x"] = 0.27,
                    ["y"] = 0.65,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.496,
                    ["z"] = 0.27,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30000000000000004,
                    ["y"] = 0.7160000000000001,
                    ["z"] = 0.24,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 1.024,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.9800000000000001,
                    ["z"] = 0.27,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 64,
            ["lod1distance"] = 167,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.1,
                ["y"] = 1.3,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Root",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Root",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 201,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uss2301/muzzle_torpedoturrets.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle01",
                        [2] = "Muzzle02",
                        [3] = "Muzzle03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Muzzle01"] = {
                    ["aimController"] = "Muzzle01",
                },
                ["Muzzle02"] = {
                    ["aimController"] = "Muzzle01",
                },
                ["Muzzle03"] = {
                    ["aimController"] = "Muzzle01",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0117",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "5ba9eecbde5e838b724cabd2c0cb774e554b853355722c20bba7fbb6a489de42",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "TorpedoTurrets",
                ["sourceProjectile"] = "/projectiles/SANHeavyCavitationTorpedo02/SANHeavyCavitationTorpedo02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "TorpedoTurrets",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Below",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle04",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Anti_Torpedo_Turret",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 80,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Anti_Torpedo_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 2,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vcm1101_cannon_plasma_small_muzzle.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Muzzle04"] = {
                    ["aimController"] = "Muzzle04",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0114",
            ["rangeMax"] = 32,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "0d0ed1dc06f64074e1b8e963ef90006aae41b11c6089162046c47856e9a6ea5e",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AjelluTorpedoDefense",
                ["sourceProjectile"] = "/projectiles/SANAjelluAntiTorpedo01/SANAjelluAntiTorpedo01_proj.bp",
            },
            ["scoSourceInterceptionLabel"] = "AjelluTorpedoDefense",
            ["scoTacticalOwned"] = true,
            ["targetWaterLimits"] = "Above",
        },
    },
}
