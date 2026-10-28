-- uss3101: Hovatham
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.75,
                ["z"] = 1.5,
            },
            ["size"] = {
                ["x"] = 2.9,
                ["y"] = 2.9,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 5,
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
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.75,
            ["z"] = 1.5,
        },
        ["collisionSize"] = {
            ["x"] = 3.5,
            ["y"] = 4,
            ["z"] = 3.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 13500,
            ["regen"] = 0,
            ["value"] = 13500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 29500,
        ["cost"] = {
            ["alloys"] = 88500,
            ["energy"] = 885000,
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
        ["displayName"] = "Hovatham",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Hovatham",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 52693.7,
            ["WaterSurface"] = 52693.7,
        },
        ["tpId"] = "uss3101",
        ["unitTypeName"] = "UnknownT3Arty",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 150,
            ["outerRadius"] = 825,
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
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "INDIRECT_FIRE",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_ARTILLERY",
        [6] = "SCFA_BUILTBYTIER3COMMANDER",
        [7] = "SCFA_BUILTBYTIER3ENGINEER",
        [8] = "SCFA_DRAGBUILD",
        [9] = "SCFA_INDIRECTFIRE",
        [10] = "SCFA_OVERLAYINDIRECTFIRE",
        [11] = "SCFA_PRODUCTFA",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SERAPHIM",
        [15] = "SCFA_SHOWATTACKRETICLE",
        [16] = "SCFA_SIZE16",
        [17] = "SCFA_SORTSTRATEGIC",
        [18] = "SCFA_STRATEGIC",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH3",
        [21] = "SCFA_VISIBLETORECON",
        [22] = "SERAPHIM",
        [23] = "STRUCTURE",
        [24] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3101/LOD0/uss3101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3101/LOD0/uss3101.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
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
                    ["particleName"] = "VFX/Death/vcd2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 2.75,
                    ["z"] = 0.7999999999999999,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 2.4699999999999998,
                    ["z"] = 2.13,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.7000000000000001,
                    ["y"] = 2.87,
                    ["z"] = 2.06,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.63,
                    ["y"] = 3.4299999999999997,
                    ["z"] = 0.7999999999999999,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.77,
                    ["y"] = 3.35,
                    ["z"] = 2.13,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 146,
            ["lod1distance"] = 380,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.75,
                ["z"] = 1.5,
            },
            ["size"] = {
                ["x"] = 2.9,
                ["y"] = 2.9,
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
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_B01",
                    ["pitchMax"] = 85,
                    ["pitchMin"] = -5,
                    ["pitchSpeed"] = 5,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 65,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 5,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom2234",
                },
            },
            ["damage"] = 5000,
            ["damageOverTimePulseCount"] = 100,
            ["damageOverTimePulseDamage"] = 40,
            ["damageRadius"] = 6,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uss3101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 5,
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
                        [1] = "Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 60,
            ["projectileTemplate"] = "psf0143",
            ["rangeMax"] = 825,
            ["rangeMin"] = 150,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 10,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "554d0170b70a1dbbe1ceba9b5abe657aebb9f3b13c7a964d1c201914ad887e10",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/SIFSuthanusArtilleryShell02/SIFSuthanusArtilleryShell02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
