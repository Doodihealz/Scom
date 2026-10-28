-- uel3002: Pillar
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["projectilesPerOnFire"] = 2,
            ["rackFireTogether"] = true,
            ["sanctuaryParallelProjectilesPerMuzzle"] = 2,
            ["sourceBlueprintSha256"] = "0b33e77eecad7fabe4b7620d46dabc921f88d9cb879a528fdbc6f01942e07f6c",
            ["sourceId"] = "UEL0202",
            ["sourceMuzzleBones"] = {
                [1] = "Turret_Muzzle_01",
                [2] = "Turret_Muzzle_02",
            },
            ["sourceScriptSha256"] = "b44fa2c38ddb66f24dc079088ba0288815e0740a1cfcf271a87472e7b48a127b",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0.4993402374766862,
                [3] = -0.24806635713200006,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0202",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 64839,
                ["entry"] = "units/UEL0202/UEL0202_LOD0.scm",
                ["sha256"] = "62fb7323dd66463b2f5d90d10ef695b55590892695e8ba5b338207c34557a089",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel3002/LOD0/uel3002_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.2237422913312912,
                        ["y"] = 0.0004754837407294799,
                        ["z"] = 0.22107610936642774,
                    },
                    ["width"] = 0.171399,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.2237422838807106,
                        ["y"] = 0.0004754927371211091,
                        ["z"] = -0.2779876590576746,
                    },
                    ["width"] = 0.171399,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.2237422838807106,
                        ["y"] = 0.0004754927371211091,
                        ["z"] = -0.2779876590576746,
                    },
                    ["width"] = 0.171399,
                },
                [4] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.2237422913312912,
                        ["y"] = 0.0004754837407294799,
                        ["z"] = 0.22107610936642774,
                    },
                    ["width"] = 0.171399,
                },
            },
            ["unit"] = "uel3002",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.9,
                ["y"] = 1.8,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1130",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1130",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.3,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 0.6,
            ["z"] = 1.2,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1500,
            ["regen"] = 0,
            ["value"] = 1500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 880,
        ["cost"] = {
            ["alloys"] = 198,
            ["energy"] = 990,
        },
    },
    ["footprint"] = {
        ["x"] = 0.9,
        ["y"] = 1.2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDALandUnit",
        },
        ["displayName"] = "Pillar",
        ["icon"] = {
            ["shape"] = "bot1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_bot1_direct.png",
        ["iconUIBuildSortPriority"] = 90,
        ["iconUIType"] = "amphibious",
        ["name"] = "Pillar",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 310.6,
            ["WaterSurface"] = 307.3,
        },
        ["tpId"] = "uel3002",
        ["unitTypeName"] = "EDAT2Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 2.7,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.7,
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.6,
                ["z"] = 0,
            },
        },
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 2.7,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 23,
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
    ["tags"] = {
        [1] = "ANTI_SURFACE",
        [2] = "BOT",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "DIRECT_FIRE",
        [6] = "EDA",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "SEABED",
        [10] = "TECH2",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_DIRECTFIRE",
        [15] = "SCFA_LAND",
        [16] = "SCFA_MOBILE",
        [17] = "SCFA_OVERLAYDIRECTFIRE",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_TANK",
        [22] = "SCFA_TECH2",
        [23] = "SCFA_UEF",
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
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved1301_death_land_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.44999999999999996,
                    ["z"] = -0.24,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.408,
                    ["z"] = 0.216,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.46799999999999997,
                    ["z"] = 0.192,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.552,
                    ["z"] = -0.24,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.54,
                    ["z"] = 0.216,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 183,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.9,
                ["y"] = 1.8,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 10,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = true,
                    ["name"] = "aelm1130",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 35,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uel3002/muzzle_frontturret01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_01",
                        [2] = "Turret_Muzzle_01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_02",
                        [2] = "Turret_Muzzle_02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "psf0151",
            ["rangeMax"] = 23,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 1.3333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "7b4cf765e643ae78c849338be82943eaba000aa10d03565dcd717182aed63460",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "FrontTurret01",
                ["sourceProjectile"] = "/projectiles/TDFGauss01/TDFGauss01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "FrontTurret01",
            },
            ["targetCheckInterval"] = 0.5,
            ["targetWaterLimits"] = "Above",
        },
    },
}
