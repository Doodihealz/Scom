-- ugl1101: Medusa
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["nativeEmpBuffSupported"] = false,
            ["sourceCollisionOffset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["sourceEmpDuration"] = 3,
            ["sourceEmpRadius"] = 2,
            ["sourceEmpTargetAllow"] = "TECH1,TECH2",
            ["sourceId"] = "URL0103",
            ["targetId"] = "ugl1101",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 2.9277801513671878e-05,
                [2] = 0.3922475889832263,
                [3] = -0.1293477844500827,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0103",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 108169,
                ["entry"] = "units/URL0103/URL0103_LOD0.scm",
                ["sha256"] = "e31f8c2a5d89b123a4b90b9a36a2024ff656207ea6442ed831838fd75a5f13f4",
            },
        },
        ["scoFieldFixCybran"] = "1.0.4",
        ["scoGameplayT1ArtilleryArc"] = true,
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl1101/LOD0/ugl1101_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.17746266722679138,
                        ["y"] = -0.0009883549821533277,
                        ["z"] = -0.08751162124899213,
                    },
                    ["width"] = 0.134257,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.17746266722679138,
                        ["y"] = -0.0009883549821533277,
                        ["z"] = -0.08751162124899213,
                    },
                    ["width"] = 0.134257,
                },
            },
            ["unit"] = "ugl1101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.45,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1110",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.55,
            ["y"] = 0.45,
            ["z"] = 0.65,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 140,
            ["regen"] = 0,
            ["value"] = 140,
        },
    },
    ["economy"] = {
        ["buildTime"] = 240,
        ["cost"] = {
            ["alloys"] = 48,
            ["energy"] = 240,
        },
    },
    ["footprint"] = {
        ["x"] = 0.55,
        ["y"] = 0.65,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardLandUnit",
        },
        ["displayName"] = "Medusa",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "indirect",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Medusa",
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
            ["Land"] = 62.6,
            ["WaterSurface"] = 65,
        },
        ["tpId"] = "ugl1101",
        ["unitTypeName"] = "GuardT1MobileArty",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 2.9,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.9,
        ["minSpeed"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 3,
        ["speed"] = 2.9,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 5,
            ["outerRadius"] = 30,
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
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "GUARD",
        [6] = "INDIRECT_FIRE",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH1",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_ARTILLERY",
        [12] = "SCFA_BUILTBYTIER1FACTORY",
        [13] = "SCFA_BUILTBYTIER2FACTORY",
        [14] = "SCFA_BUILTBYTIER3FACTORY",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_INDIRECTFIRE",
        [17] = "SCFA_LAND",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_OVERLAYINDIRECTFIRE",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_TECH1",
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
                    ["particleName"] = "VFX/Death/vgd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.099,
                    ["y"] = 0.1125,
                    ["z"] = -0.13,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.12100000000000001,
                    ["y"] = 0.081,
                    ["z"] = 0.11699999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11000000000000001,
                    ["y"] = 0.12600000000000003,
                    ["z"] = 0.10400000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.099,
                    ["y"] = 0.189,
                    ["z"] = -0.13,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.12100000000000001,
                    ["y"] = 0.18000000000000002,
                    ["z"] = 0.11699999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 172,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.35,
                ["y"] = 0.45,
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
                    ["aimTolerance"] = 1,
                    ["defaultPitchAdjustment"] = 45,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 70,
                    ["poseResetTime"] = 10,
                    ["projectileSpeed"] = 14,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 70,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom1210",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 195,
            ["damageFriendly"] = false,
            ["damageRadius"] = 1.5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugl1101/muzzle_maingun.sanvfx",
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
            ["muzzleGroupTimeOut"] = 10,
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
            ["projectileLifetime"] = 20,
            ["projectileTemplate"] = "psf0097",
            ["rangeMax"] = 30,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "95827fbff5673ff590b19e04d652f2246b3b46b6c1b8c26d7cb334509fdabcd8",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/CIFGrenade01/CIFGrenade01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetCheckInterval"] = 1,
            ["targetWaterLimits"] = "Above",
        },
    },
}
