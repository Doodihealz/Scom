-- usl2806: Yenzyne
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0.05718960762023927,
                [2] = 0.63179641416836,
                [3] = 0.025735979890404742,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0203",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 88044,
                ["entry"] = "units/XSL0203/XSL0203_lod0.scm",
                ["sha256"] = "360ba2a17343849808777273ac165acbbec539dacec0ac195b9aa253aa3a126a",
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.8,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 15,
                ["rateMinTenths"] = 5,
                ["weight"] = 100,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1420",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 0.5,
            ["z"] = 1.2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1300,
            ["regen"] = 0,
            ["value"] = 1300,
        },
    },
    ["economy"] = {
        ["buildTime"] = 880,
        ["cost"] = {
            ["alloys"] = 220,
            ["energy"] = 1320,
        },
    },
    ["footprint"] = {
        ["x"] = 0.9,
        ["y"] = 1.2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Yenzyne",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "none",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_none.png",
        ["iconUIBuildSortPriority"] = 90,
        ["iconUIType"] = "amphibious",
        ["name"] = "Yenzyne",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usl2806",
        ["unitTypeName"] = "UnknownT2MobileTransmitter",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["movement"] = {
        ["acceleration"] = 3.7,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["deceleration"] = 3.7,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0.125,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 6,
        ["speed"] = 3.7,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "MOBILE",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER2FACTORY",
        [6] = "SCFA_BUILTBYTIER3FACTORY",
        [7] = "SCFA_DIRECTFIRE",
        [8] = "SCFA_HOVER",
        [9] = "SCFA_LAND",
        [10] = "SCFA_MOBILE",
        [11] = "SCFA_OVERLAYDIRECTFIRE",
        [12] = "SCFA_PRODUCTFA",
        [13] = "SCFA_RECLAIMABLE",
        [14] = "SCFA_SELECTABLE",
        [15] = "SCFA_SERAPHIM",
        [16] = "SCFA_TANK",
        [17] = "SCFA_TECH2",
        [18] = "SCFA_VISIBLETORECON",
        [19] = "SERAPHIM",
        [20] = "TECH2",
        [21] = "UTILITY",
        [22] = "HOVER",
        [23] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/usl2806/LOD0/usl2806.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl2806/LOD0/usl2806.sananimation",
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.375,
                    ["z"] = -0.24,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.216,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.39,
                    ["z"] = 0.192,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.24,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.45,
                    ["z"] = 0.216,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 65,
            ["lod1distance"] = 171,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.8,
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
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 175,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl2806/muzzle_taucannon01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
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
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0135",
            ["rangeMax"] = 18,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "1e24de16c6af766f0bda9f3121af9eda545c73388f2cb9a69f6615942e6c6822",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "TauCannon01",
                ["sourceProjectile"] = "/projectiles/SDFTauCannon01/SDFTauCannon01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "TauCannon01",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
