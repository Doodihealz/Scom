-- usl2101: Ythisah
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -0.10541444349288942,
                [2] = 0.8145100889463687,
                [3] = 0.4317837281835301,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "XSL0111",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 66826,
                ["entry"] = "units/XSL0111/XSL0111_lod0.scm",
                ["sha256"] = "45075e3bb56f93b678095f4409f6b365bd431912b1c90a5ee47f0116dc6fe6d0",
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/usl2101/LOD0/usl2101_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.45990992116928103,
                        ["y"] = -3.915960378880756e-08,
                        ["z"] = -0.4281820144653309,
                    },
                    ["width"] = 0.192746,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.16953824239969256,
                        ["y"] = 4.5159790294443947e-08,
                        ["z"] = 0.4432027254104587,
                    },
                    ["width"] = 0.192747,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.33340542984008786,
                        ["y"] = -5.3577195752857465e-09,
                        ["z"] = -0.2852562751770038,
                    },
                    ["width"] = 0.192746,
                },
            },
            ["unit"] = "usl2101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.225,
                ["z"] = -0.1,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.95,
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
            ["y"] = 0.225,
            ["z"] = -0.1,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 0.45,
            ["z"] = 1.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 800,
            ["regen"] = 0,
            ["value"] = 800,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1000,
        ["cost"] = {
            ["alloys"] = 200,
            ["energy"] = 1500,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1.6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimLandUnit",
        },
        ["displayName"] = "Ythisah",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "indirect",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_indirect.png",
        ["iconUIBuildSortPriority"] = 60,
        ["iconUIType"] = "amphibious",
        ["name"] = "Ythisah",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usl2101",
        ["unitTypeName"] = "UnknownT2LandDroneCarrier",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 2.85,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.85,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 6,
        ["speed"] = 2.85,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 4,
            ["outerRadius"] = 60,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "DRONE_CARRIER",
        [4] = "MOBILE",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_BUILTBYTIER2FACTORY",
        [7] = "SCFA_BUILTBYTIER3FACTORY",
        [8] = "SCFA_INDIRECTFIRE",
        [9] = "SCFA_LAND",
        [10] = "SCFA_MOBILE",
        [11] = "SCFA_OVERLAYINDIRECTFIRE",
        [12] = "SCFA_PRODUCTFA",
        [13] = "SCFA_RECLAIMABLE",
        [14] = "SCFA_SELECTABLE",
        [15] = "SCFA_SERAPHIM",
        [16] = "SCFA_SILO",
        [17] = "SCFA_TECH2",
        [18] = "SCFA_VISIBLETORECON",
        [19] = "SERAPHIM",
        [20] = "TECH2",
        [21] = "LAND",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animreload"] = {
                ["clipName"] = "AnimReload",
                ["sanAnimationPath"] = "Units/usl2101/LOD0/usl2101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usl2101/LOD0/usl2101.sananimation",
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
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.3375,
                    ["z"] = -0.42000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.306,
                    ["z"] = 0.18799999999999997,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.35100000000000003,
                    ["z"] = 0.156,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.41400000000000003,
                    ["z"] = -0.42000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.405,
                    ["z"] = 0.18799999999999997,
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
                ["y"] = 0.225,
                ["z"] = -0.1,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.95,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "missile",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "missile",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 3,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "missile",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 405,
            ["damageRadius"] = 0.5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usl2101/muzzle_missilerack.sanvfx",
            },
            ["firingRandomness"] = 0,
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
                        [1] = "missile",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["missile"] = {
                    ["aimController"] = "missile",
                },
            },
            ["projectileLifetime"] = 20,
            ["projectileTemplate"] = "psf0138",
            ["rangeMax"] = 60,
            ["rangeMin"] = 4,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 6.66666666666667,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "33b12c7115c72cbca467e9084ff507094991641359cf7d28948d42c8cca09ece",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack",
                ["sourceProjectile"] = "/projectiles/SIFLaanseTacticalMissile01/SIFLaanseTacticalMissile01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileRack",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
