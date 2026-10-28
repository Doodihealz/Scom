-- uss2102: T2 Tactical Missile Launcher
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
            ["cycleReload"] = 0,
            ["defaultAutoBuild"] = true,
            ["damage"] = 6000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 2,
            ["deployDuration"] = 1,
            ["deployKey"] = "fa_deploy",
            ["deployRate"] = 1,
            ["domeRecoil"] = false,
            ["initialAmmo"] = 0,
            ["lifetime"] = 30,
            ["maxAmmo"] = 20,
            ["muzzleVelocity"] = 10,
            ["muzzles"] = {
                [1] = "Projectile",
            },
            ["packedKey"] = "fa_packed",
            ["projectile"] = "pst004",
            ["rangeMax"] = 256,
            ["rangeMin"] = 15,
            ["reload"] = 0.3333333333333333,
            ["repackTimeout"] = 3,
            ["role"] = "launcher",
            ["sourceId"] = "XSB2108",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.4,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.45,
                ["y"] = 0.65,
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
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.4,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.65,
            ["y"] = 0.8,
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
        ["buildTime"] = 700,
        ["cost"] = {
            ["alloys"] = 825,
            ["energy"] = 4500,
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
        ["displayName"] = "T2 Tactical Missile Launcher",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Ythis",
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
        ["tpId"] = "uss2102",
        ["unitTypeName"] = "UnknownT2Structure",
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
        [3] = "SCFA_ALLUNITS",
        [4] = "SCFA_BUILTBYTIER2COMMANDER",
        [5] = "SCFA_BUILTBYTIER2ENGINEER",
        [6] = "SCFA_BUILTBYTIER3COMMANDER",
        [7] = "SCFA_BUILTBYTIER3ENGINEER",
        [8] = "SCFA_DRAGBUILD",
        [9] = "SCFA_INDIRECTFIRE",
        [10] = "SCFA_OVERLAYINDIRECTFIRE",
        [11] = "SCFA_PRODUCTFA",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SERAPHIM",
        [15] = "SCFA_SILO",
        [16] = "SCFA_SIZE4",
        [17] = "SCFA_SORTSTRATEGIC",
        [18] = "SCFA_STRATEGIC",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TACTICALMISSILEPLATFORM",
        [21] = "SCFA_TECH2",
        [22] = "SCFA_VISIBLETORECON",
        [23] = "SERAPHIM",
        [24] = "STRUCTURE",
        [25] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["fa_deploy"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2102/LOD0/uss2102.sananimation",
            },
            ["fa_packed"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2102/LOD0/uss2102.sananimation",
            },
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2102/LOD0/uss2102.sananimation",
            },
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2102/LOD0/uss2102.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2102/LOD0/uss2102.sananimation",
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
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.6000000000000001,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.544,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13,
                    ["y"] = 0.6240000000000001,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.736,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.7200000000000001,
                    ["z"] = 0.18,
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
                ["y"] = 0.4,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.45,
                ["y"] = 0.65,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Projectile",
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
                        [1] = "Projectile",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Projectile"] = {
                    ["aimController"] = "Projectile",
                },
            },
            ["name"] = "CruiseMissile",
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "pst004",
            ["rangeMax"] = 256,
            ["rangeMin"] = 15,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.2,
            ["reloadTime"] = 0.3333333333333333,
            ["scoTacticalOwned"] = true,
        },
    },
}
