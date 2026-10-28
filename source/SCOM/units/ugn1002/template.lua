-- ugn1002: Tier 1: Sliver
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "7BA676FB88759EA088BA95B6986B66CF7ED7F71779E78FCA599EDC377AE55C4D",
            ["sourceId"] = "URS0203",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.05,
            ["targetId"] = "ugn1002",
            ["textureResolution"] = 2048,
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URS0203",
            ["targetId"] = "ugn1002",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.36,
                ["y"] = 1.45,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 0.5,
            ["z"] = 2.3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 525,
            ["regen"] = 0,
            ["value"] = 525,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1440,
        ["cost"] = {
            ["alloys"] = 360,
            ["energy"] = 2880,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefault",
            [2] = "SubmarineUnit",
        },
        ["displayName"] = "Tier 1: Sliver",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Sliver",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Submerge"] = true,
        },
        ["tpId"] = "ugn1002",
    },
    ["intel"] = {
        ["radarRadius"] = 0,
        ["sonarRadius"] = 60,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 6,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Submarine",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Submarine",
        },
        ["deceleration"] = 6,
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.62,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
                ["z"] = 2.3,
            },
        },
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = -1.5,
        ["referenceAltitude"] = "Water",
        ["rotationSpeed"] = 80,
        ["sortOrder"] = 5,
        ["speed"] = 6,
        ["submergedAltitude"] = -1.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "UnderWater",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 32,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_FACTORY",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "GUARD",
        [5] = "MOBILE",
        [6] = "NAVAL",
        [7] = "TECH1",
        [8] = "ANTI_SURFACE",
        [9] = "DIRECT_FIRE",
        [10] = "INDIRECT_FIRE",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_ANTIAIR",
        [13] = "SCFA_ANTIMISSILE",
        [14] = "SCFA_BUILTBYTIER1FACTORY",
        [15] = "SCFA_BUILTBYTIER2FACTORY",
        [16] = "SCFA_BUILTBYTIER3FACTORY",
        [17] = "SCFA_CYBRAN",
        [18] = "SCFA_DIRECTFIRE",
        [19] = "SCFA_MOBILE",
        [20] = "SCFA_NAVAL",
        [21] = "SCFA_OVERLAYANTINAVY",
        [22] = "SCFA_OVERLAYDIRECTFIRE",
        [23] = "SCFA_OVERLAYSONAR",
        [24] = "SCFA_PRODUCTSC1",
        [25] = "SCFA_RECLAIMABLE",
        [26] = "SCFA_SELECTABLE",
        [27] = "SCFA_SUBMERSIBLE",
        [28] = "SCFA_T1SUBMARINE",
        [29] = "SCFA_TECH1",
        [30] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animasink_1"] = {
                ["clipName"] = "AnimAsink",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1002/LOD0/ugn1002.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn1002/LOD0/ugn1002.sananimation",
            },
        },
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.125,
                    ["z"] = -0.45999999999999996,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.09,
                    ["z"] = 0.414,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.14,
                    ["z"] = 0.368,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.21,
                    ["z"] = -0.45999999999999996,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.2,
                    ["z"] = 0.414,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 150,
            ["lod1distance"] = 390,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.36,
                ["y"] = 1.45,
            },
            ["thickness"] = 0.28,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Left_Projectile",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Left_Projectile",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Projectile",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn1002/muzzle_torpedo01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Water",
                [2] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.8,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Left_Projectile"] = {
                    ["aimController"] = "Left_Projectile",
                },
                ["Right_Projectile"] = {
                    ["aimController"] = "Left_Projectile",
                },
            },
            ["name"] = "Torpedo01",
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0012",
            ["rangeMax"] = 32,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Torpedo01",
                ["sourceProjectile"] = "/projectiles/CANTorpedoNanite01/CANTorpedoNanite01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Torpedo01",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Below",
        },
        [2] = {
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
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 120,
                    ["pitchMin"] = -20,
                    ["pitchSpeed"] = 90,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 10,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn1002/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
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
            ["name"] = "MainGun",
            ["projectileLifetime"] = 1.6,
            ["projectileTemplate"] = "psf0017",
            ["rangeMax"] = 32,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "af6d6d5a993f916fce71159d06b894d8e1269fe8621913b4064fc668f402ac6b",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/CDFLaserHeavy01/CDFLaserHeavy01_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "MainGun",
            },
            ["targetWaterLimits"] = "Above",
            ["waterSensor"] = {
                ["bone"] = "Turret_Muzzle",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["size"] = {
                    ["x"] = 0.25,
                    ["y"] = 0.25,
                    ["z"] = 0.25,
                },
            },
        },
    },
}
