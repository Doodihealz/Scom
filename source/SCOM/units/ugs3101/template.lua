-- ugs3101: Disruptor
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoFieldFixCybran"] = "1.0.4",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.78,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 6.5,
                ["y"] = 6.5,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 5.4,
            ["y"] = 6.5,
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
            ["y"] = 1.78,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 6.4,
            ["y"] = 3.8,
            ["z"] = 6.4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 13000,
            ["regen"] = 3,
            ["value"] = 13000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 40000,
        ["cost"] = {
            ["alloys"] = 40000,
            ["energy"] = 400000,
        },
    },
    ["footprint"] = {
        ["x"] = 6.5,
        ["y"] = 6.5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Disruptor",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Disruptor",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 52720.9,
            ["WaterSurface"] = 52720.9,
        },
        ["tpId"] = "ugs3101",
        ["unitTypeName"] = "GuardT3Arty",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 150,
            ["outerRadius"] = 700,
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
        ["x"] = 8,
        ["y"] = 8,
    },
    ["tags"] = {
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "GUARD",
        [4] = "INDIRECT_FIRE",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_ARTILLERY",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_CYBRAN",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_INDIRECTFIRE",
        [14] = "SCFA_OVERLAYINDIRECTFIRE",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SHOWATTACKRETICLE",
        [19] = "SCFA_SIZE16",
        [20] = "SCFA_SORTSTRATEGIC",
        [21] = "SCFA_STRATEGIC",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TECH3",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/Death/vgd2301_death_building_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.152,
                    ["y"] = 2.73,
                    ["z"] = -1.2800000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.4080000000000001,
                    ["y"] = 2.464,
                    ["z"] = 1.152,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.2800000000000002,
                    ["y"] = 2.8440000000000003,
                    ["z"] = 1.024,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.152,
                    ["y"] = 3.376,
                    ["z"] = -1.2800000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.4080000000000001,
                    ["y"] = 3.3,
                    ["z"] = 1.152,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 252,
            ["lod1distance"] = 655,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.78,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 6.5,
                ["y"] = 6.5,
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
                        ["y"] = -1,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 80,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 5,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 30,
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
                    ["name"] = "agom2234",
                },
            },
            ["damage"] = 4600,
            ["damageFriendly"] = true,
            ["damageRadius"] = 8,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugs3101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 1.5,
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
            ["projectileLifetime"] = 120,
            ["projectileTemplate"] = "psf0096",
            ["rangeMax"] = 700,
            ["rangeMin"] = 150,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 10,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
