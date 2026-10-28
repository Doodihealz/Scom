-- ues2102: T2 Tactical Missile Launcher
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
            ["deployDuration"] = 4,
            ["deployKey"] = "fa_deploy",
            ["deployRate"] = 2,
            ["domeRecoil"] = false,
            ["initialAmmo"] = 0,
            ["lifetime"] = 30,
            ["maxAmmo"] = 12,
            ["muzzleVelocity"] = 10,
            ["muzzles"] = {
                [1] = "Muzzle",
            },
            ["packedKey"] = "fa_packed",
            ["projectile"] = "pst001",
            ["rangeMax"] = 256,
            ["rangeMin"] = 15,
            ["reload"] = 0.3333333333333333,
            ["repackTimeout"] = 3,
            ["role"] = "launcher",
            ["sourceId"] = "UEB2108",
            ["version"] = "1.0.0",
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2120",
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
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 800,
            ["energy"] = 4000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
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
        ["name"] = "Aloha",
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
        ["tpId"] = "ues2102",
        ["unitTypeName"] = "EDAT2DroneLauncher",
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
        [3] = "EDA",
        [4] = "STRUCTURE",
        [5] = "TECH2",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_BUILTBYTIER2COMMANDER",
        [8] = "SCFA_BUILTBYTIER2ENGINEER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_INDIRECTFIRE",
        [12] = "SCFA_OVERLAYINDIRECTFIRE",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SHOWATTACKRETICLE",
        [17] = "SCFA_SILO",
        [18] = "SCFA_SIZE4",
        [19] = "SCFA_SORTSTRATEGIC",
        [20] = "SCFA_STRATEGIC",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TACTICALMISSILEPLATFORM",
        [23] = "SCFA_TECH2",
        [24] = "SCFA_UEF",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["fa_deploy"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2102/LOD0/ues2102.sananimation",
            },
            ["fa_packed"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2102/LOD0/ues2102.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2102/LOD0/ues2102.sananimation",
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
                    ["particleName"] = "VFX/Death/ved2201_death_building_medium.sanvfx",
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
        ["model"] = "Units/ues2102/LOD0/ues2102_lod0.sanmodel",
        ["selection"] = {
            ["size"] = {
                ["x"] = 1.8,
                ["y"] = 1.8,
            },
        },
        ["skeleton"] = "Units/ues2102/LOD0/ues2102.sanskeleton",
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle",
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
                        [1] = "Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Muzzle"] = {
                    ["aimController"] = "Muzzle",
                },
            },
            ["name"] = "CruiseMissile",
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "pst001",
            ["rangeMax"] = 256,
            ["rangeMin"] = 15,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.2,
            ["reloadTime"] = 0.3333333333333333,
            ["scoTacticalOwned"] = true,
        },
    },
}
