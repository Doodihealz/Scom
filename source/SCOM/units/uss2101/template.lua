-- uss2101: Zthuthaam
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
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
            ["y"] = 0.35,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1.2,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2850,
            ["regen"] = 0,
            ["value"] = 2850,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1900,
        ["cost"] = {
            ["alloys"] = 2660,
            ["energy"] = 19000,
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
        ["displayName"] = "Zthuthaam",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Zthuthaam",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 1114.5,
            ["WaterSurface"] = 1473,
        },
        ["tpId"] = "uss2101",
        ["unitTypeName"] = "UnknownT2Arty",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 5,
            ["outerRadius"] = 128,
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "INDIRECT_FIRE",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_ARTILLERY",
        [7] = "SCFA_BUILTBYTIER2COMMANDER",
        [8] = "SCFA_BUILTBYTIER2ENGINEER",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_INDIRECTFIRE",
        [13] = "SCFA_OVERLAYINDIRECTFIRE",
        [14] = "SCFA_PRODUCTFA",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SERAPHIM",
        [18] = "SCFA_SHOWATTACKRETICLE",
        [19] = "SCFA_SIZE4",
        [20] = "SCFA_SORTSTRATEGIC",
        [21] = "SCFA_STRATEGIC",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TECH2",
        [24] = "SCFA_VISIBLETORECON",
        [25] = "SERAPHIM",
        [26] = "STRUCTURE",
        [27] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2101/LOD0/uss2101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2101/LOD0/uss2101.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.6499999999999999,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.566,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.6859999999999999,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.854,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.83,
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
                ["y"] = 0.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
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
                    ["pitchBone"] = "Turret_Recoil",
                    ["pitchMax"] = 80,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 5,
                    ["poseResetTime"] = -1,
                    ["projectileSpeed"] = 26.13,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 50,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom2224",
                },
            },
            ["damage"] = 2400,
            ["damageRadius"] = 3,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uss2101/muzzle_maingun.sanvfx",
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
            ["projectileTemplate"] = "psf0145",
            ["rangeMax"] = 128,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 20,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "fe81074624f3863fc571363faf508c918a6714ff13691650cc77f5c31de83d8c",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/SIFZthuthaamArtilleryShell02/SIFZthuthaamArtilleryShell02_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
