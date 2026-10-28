-- ugs2102: T2 Tactical Missile Launcher
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoTactical"] = {
            ["barrelSpin"] = false,
            ["beam"] = false,
            ["beamLifetime"] = 0,
            ["buildPower"] = 80,
            ["buildTime"] = 2400,
            ["charge"] = 1.5,
            ["cost"] = {
                ["alloys"] = 180,
                ["energy"] = 3600,
            },
            ["cycleReload"] = 3.5,
            ["defaultAutoBuild"] = true,
            ["damage"] = 6000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 2,
            ["deployDuration"] = 0,
            ["deployKey"] = "fa_deploy",
            ["deployRate"] = 1,
            ["domeRecoil"] = false,
            ["initialAmmo"] = 0,
            ["lifetime"] = 30,
            ["maxAmmo"] = 10,
            ["muzzleVelocity"] = 10,
            ["muzzles"] = {
                [1] = "Projectile01",
                [2] = "Projectile02",
                [3] = "Projectile03",
                [4] = "Projectile04",
            },
            ["packedKey"] = "fa_packed",
            ["projectile"] = "pst003",
            ["rangeMax"] = 256,
            ["rangeMin"] = 15,
            ["reload"] = 0.3333333333333333,
            ["repackTimeout"] = 0,
            ["role"] = "launcher",
            ["sourceId"] = "URB2108",
            ["version"] = "1.0.0",
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
            ["y"] = 0.5,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1,
            ["z"] = 1,
        },
    },
    ["construction"] = {
        ["buildPower"] = 80,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1500,
            ["value"] = 1500,
        },
    },
    ["economy"] = {
        ["buildPower"] = 80,
        ["buildTime"] = 850,
        ["cost"] = {
            ["alloys"] = 850,
            ["energy"] = 5100,
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
        ["displayName"] = "T2 Tactical Missile Launcher",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "TML-4",
        ["orders"] = {
            ["ManualFire1"] = true,
            ["ManualFire2"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ugs2102",
        ["unitTypeName"] = "GuardT2DroneLauncher",
    },
    ["intel"] = {
        ["visionRadius"] = 24,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 15,
            ["outerRadius"] = 256,
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
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "GUARD",
        [4] = "STRUCTURE",
        [5] = "TECH2",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_BUILTBYTIER2COMMANDER",
        [8] = "SCFA_BUILTBYTIER2ENGINEER",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_CYBRAN",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_INDIRECTFIRE",
        [14] = "SCFA_OVERLAYINDIRECTFIRE",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SILO",
        [19] = "SCFA_SIZE4",
        [20] = "SCFA_SORTSTRATEGIC",
        [21] = "SCFA_STRATEGIC",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TACTICALMISSILEPLATFORM",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_VISIBLETORECON",
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vgd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.75,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.6799999999999999,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.78,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.9199999999999999,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.9,
                    ["z"] = 0.18,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 69,
            ["lod1distance"] = 179,
        },
        ["model"] = "Units/ugs2102/LOD0/ugs2102_lod0.sanmodel",
        ["selection"] = {
            ["size"] = {
                ["x"] = 1.8,
                ["y"] = 1.8,
            },
        },
        ["skeleton"] = "Units/ugs2102/LOD0/ugs2102.sanskeleton",
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Projectile01",
                    ["aimTolerance"] = 5,
                    ["leadTarget"] = false,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 10,
                    ["solverType"] = "NoArc",
                },
            },
            ["damage"] = 6000,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Water",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Projectile01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Projectile02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Projectile03",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Projectile04",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Projectile01"] = {
                    ["aimController"] = "Projectile01",
                },
                ["Projectile02"] = {
                    ["aimController"] = "Projectile01",
                },
                ["Projectile03"] = {
                    ["aimController"] = "Projectile01",
                },
                ["Projectile04"] = {
                    ["aimController"] = "Projectile01",
                },
            },
            ["name"] = "CruiseMissile",
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "pst003",
            ["rangeMax"] = 256,
            ["rangeMin"] = 15,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.2,
            ["reloadTime"] = 0.3333333333333333,
            ["scoTacticalOwned"] = true,
        },
    },
}
