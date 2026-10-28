-- ugs2402: T2 Tactical Missile Defense
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoTactical"] = {
            ["barrelSpin"] = false,
            ["beam"] = true,
            ["beamLifetime"] = 0.1,
            ["buildPower"] = 0,
            ["buildTime"] = 0,
            ["charge"] = 0,
            ["cost"] = {
                ["alloys"] = 0,
                ["energy"] = 0,
            },
            ["cycleReload"] = 0,
            ["damage"] = 1,
            ["damageFriendly"] = true,
            ["damageRadius"] = 0,
            ["deployDuration"] = 0,
            ["deployKey"] = "fa_deploy",
            ["deployRate"] = 1,
            ["domeRecoil"] = false,
            ["initialAmmo"] = 0,
            ["lifetime"] = 30,
            ["maxAmmo"] = 0,
            ["muzzleVelocity"] = 0,
            ["muzzles"] = {
                [1] = "Turret_Muzzle",
            },
            ["packedKey"] = "fa_packed",
            ["projectile"] = "pst009",
            ["rangeMax"] = 30,
            ["rangeMin"] = 0,
            ["reload"] = 2,
            ["repackTimeout"] = 0,
            ["role"] = "defense",
            ["sourceId"] = "URB4201",
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
            ["y"] = 1.2,
            ["z"] = -0.1,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 2.4,
            ["z"] = 0.6,
        },
    },
    ["construction"] = {
        ["buildPower"] = 0,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 950,
            ["value"] = 950,
        },
    },
    ["economy"] = {
        ["buildPower"] = 0,
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 280,
            ["energy"] = 3200,
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
        ["displayName"] = "T2 Tactical Missile Defense",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "none",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_none.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Zapper",
        ["orders"] = {
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
        ["tpId"] = "ugs2402",
        ["unitTypeName"] = "GuardT2AntiDroneDefence",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 30,
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ANTI_DRONE",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "DEFENCE",
        [5] = "GUARD",
        [6] = "LAND",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ANTIMISSILE",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_DEFENSE",
        [17] = "SCFA_DRAGBUILD",
        [18] = "SCFA_OVERLAYDEFENSE",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTDEFENSE",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
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
                    ["particleName"] = "VFX/Death/vgd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 1.7999999999999998,
                    ["z"] = -0.22,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 1.632,
                    ["z"] = 0.007999999999999993,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 1.8719999999999999,
                    ["z"] = -0.0040000000000000036,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 2.208,
                    ["z"] = -0.22,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 2.16,
                    ["z"] = 0.007999999999999993,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 65,
            ["lod1distance"] = 171,
        },
        ["model"] = "Units/ugs2402/LOD0/ugs2402_lod0.sanmodel",
        ["selection"] = {
            ["size"] = {
                ["x"] = 1.36,
                ["y"] = 1.36,
            },
        },
        ["skeleton"] = "Units/ugs2402/LOD0/ugs2402.sanskeleton",
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle",
                    ["aimTolerance"] = 0.5,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Muzzle",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 100,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 720,
                },
            },
            ["beam"] = {
                ["cullDistance"] = 400,
                ["fadeInTime"] = 0,
                ["fadeOutTime"] = 0.01,
                ["renderLifetime"] = 0.1,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/SCOM/Source/Beams/bfa_zapper_0.sanmaterial",
                        ["model"] = "VFX/SCOM/Source/Beams/bfa_zapper_0.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 1,
            ["damage"] = 1,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
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
            ["name"] = "Turret01",
            ["projectileLifetime"] = 30,
            ["projectileTemplate"] = "pbf0005",
            ["rangeMax"] = 30,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.2,
            ["reloadTime"] = 2,
            ["scoTacticalBeam"] = true,
            ["scoTacticalOwned"] = true,
        },
    },
}
