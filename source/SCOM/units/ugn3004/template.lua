-- ugn3004: Tier 3: Plan B
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 0,
            ["sourceBlueprintSha256"] = "4615FBB14DC92DBA99F93128D26DC0BB8C10E2D8BE169B4E943FB841AFA64518",
            ["sourceId"] = "URS0304",
            ["sourceMinimumWaterDepth"] = 0,
            ["sourceUniformScale"] = 0.05,
            ["targetId"] = "ugn3004",
            ["textureResolution"] = 2048,
        },
        ["scoFieldFixPrefabCompletion"] = "1.0.1",
        ["scoSourceInterception"] = {
            ["silo"] = {
                ["autoIntercept"] = false,
                ["buildPower"] = 1080,
                ["buildTime"] = 324000,
                ["charge"] = 0,
                ["cost"] = {
                    ["alloys"] = 15000,
                    ["energy"] = 1800000,
                },
                ["cycleReload"] = 0,
                ["damage"] = 0,
                ["damageRadius"] = 0,
                ["deployDuration"] = 0,
                ["deployKey"] = "sco_source_launch",
                ["deployRate"] = 1,
                ["initialAmmo"] = 0,
                ["maxAmmo"] = 3,
                ["muzzleVelocity"] = 0,
                ["muzzles"] = {
                    [1] = "Projectile_Center",
                },
                ["nukeRings"] = {
                    [1] = {
                        ["damage"] = 70000,
                        ["radius"] = 30,
                        ["ticks"] = 24,
                        ["totalTime"] = 0,
                    },
                    [2] = {
                        ["damage"] = 500,
                        ["radius"] = 40,
                        ["ticks"] = 20,
                        ["totalTime"] = 0,
                    },
                },
                ["preserveAttack"] = true,
                ["projectile"] = "psf0181",
                ["rangeMax"] = 1024,
                ["rangeMin"] = 128,
                ["reload"] = 1,
                ["repackTimeout"] = 0,
                ["role"] = "launcher",
                ["sourceId"] = "URS0304",
                ["sourceLabel"] = "NukeMissile",
                ["sourceStockpile"] = true,
                ["version"] = "1.0.0",
            },
            ["sourceId"] = "URS0304",
            ["targetId"] = "ugn3004",
            ["weapons"] = {
                ["NukeMissile"] = {
                    ["counted"] = true,
                    ["damage"] = 0,
                    ["interval"] = 0.5,
                    ["muzzleVelocity"] = 0,
                    ["muzzles"] = {
                        [1] = "Projectile_Center",
                    },
                    ["projectile"] = "psf0181",
                    ["rangeMax"] = 1024,
                    ["rangeMin"] = 128,
                    ["reload"] = 1,
                    ["sourceIndex"] = 3,
                    ["sourceLabel"] = "NukeMissile",
                },
            },
        },
        ["scoTactical"] = {
            ["autoIntercept"] = false,
            ["buildPower"] = 1080,
            ["buildTime"] = 324000,
            ["charge"] = 0,
            ["cost"] = {
                ["alloys"] = 15000,
                ["energy"] = 1800000,
            },
            ["cycleReload"] = 0,
            ["damage"] = 0,
            ["damageRadius"] = 0,
            ["deployDuration"] = 0,
            ["deployKey"] = "sco_source_launch",
            ["deployRate"] = 1,
            ["initialAmmo"] = 0,
            ["maxAmmo"] = 3,
            ["muzzleVelocity"] = 0,
            ["muzzles"] = {
                [1] = "Projectile_Center",
            },
            ["nukeRings"] = {
                [1] = {
                    ["damage"] = 70000,
                    ["radius"] = 30,
                    ["ticks"] = 24,
                    ["totalTime"] = 0,
                },
                [2] = {
                    ["damage"] = 500,
                    ["radius"] = 40,
                    ["ticks"] = 20,
                    ["totalTime"] = 0,
                },
            },
            ["preserveAttack"] = true,
            ["projectile"] = "psf0181",
            ["rangeMax"] = 1024,
            ["rangeMin"] = 128,
            ["reload"] = 1,
            ["repackTimeout"] = 0,
            ["role"] = "launcher",
            ["sourceId"] = "URS0304",
            ["sourceLabel"] = "NukeMissile",
            ["sourceStockpile"] = true,
            ["version"] = "1.0.0",
        },
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "URS0304",
            ["targetId"] = "ugn3004",
        },
        ["seaParityUnsupported"] = {
            ["nukeSilo"] = true,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0.25,
            },
            ["size"] = {
                ["x"] = 0.95,
                ["y"] = 2.6,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.1,
            ["z"] = 0.25,
        },
        ["collisionSize"] = {
            ["x"] = 1.5,
            ["y"] = 0.7,
            ["z"] = 3.75,
        },
    },
    ["construction"] = {
        ["buildPower"] = 1080,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3500,
            ["regen"] = 0,
            ["value"] = 3500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 20000,
        ["cost"] = {
            ["alloys"] = 11000,
            ["energy"] = 800000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardNavalUnit",
        },
        ["displayName"] = "Tier 3: Plan B",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "Plan B",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["ManualFire1"] = true,
            ["ManualFire2"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ugn3004",
    },
    ["intel"] = {
        ["radarRadius"] = 0,
        ["sonarRadius"] = 60,
        ["visionRadius"] = 16,
    },
    ["movement"] = {
        ["acceleration"] = 3.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Submarine",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Submarine",
        },
        ["deceleration"] = 3.5,
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.1,
                ["z"] = 0.25,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 0.7,
                ["z"] = 3.75,
            },
        },
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = -2,
        ["referenceAltitude"] = "Water",
        ["rotationSpeed"] = 50,
        ["sortOrder"] = 5,
        ["speed"] = 3.5,
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
        [7] = {
            ["innerRadius"] = 15,
            ["outerRadius"] = 150,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 16,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_FACTORY",
        [2] = "GUARD",
        [3] = "MOBILE",
        [4] = "NAVAL",
        [5] = "TECH3",
        [6] = "ANTI_SURFACE",
        [7] = "INDIRECT_FIRE",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3FACTORY",
        [10] = "SCFA_CYBRAN",
        [11] = "SCFA_INDIRECTFIRE",
        [12] = "SCFA_MOBILE",
        [13] = "SCFA_NAVAL",
        [14] = "SCFA_NUKE",
        [15] = "SCFA_NUKESUB",
        [16] = "SCFA_OVERLAYANTINAVY",
        [17] = "SCFA_OVERLAYINDIRECTFIRE",
        [18] = "SCFA_OVERLAYSONAR",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SHOWATTACKRETICLE",
        [23] = "SCFA_SILO",
        [24] = "SCFA_SUBMERSIBLE",
        [25] = "SCFA_TECH3",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animasink_1"] = {
                ["clipName"] = "AnimAsink",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3004/LOD0/ugn3004.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugn3004/LOD0/ugn3004.sananimation",
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
                    ["x"] = 0.27,
                    ["y"] = 0.275,
                    ["z"] = -0.5,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.226,
                    ["z"] = 0.9249999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30000000000000004,
                    ["y"] = 0.29600000000000004,
                    ["z"] = 0.85,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 0.394,
                    ["z"] = -0.5,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 0.38,
                    ["z"] = 0.9249999999999999,
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
                ["y"] = 0.1,
                ["z"] = 0.25,
            },
            ["size"] = {
                ["x"] = 0.95,
                ["y"] = 2.6,
            },
            ["thickness"] = 0.28,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Projectile_Left",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Projectile_Left",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Projectile_Left",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 60,
                },
                [2] = {
                    ["aimBone"] = "Projectile_Right",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Projectile_Right",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Projectile_Right",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 60,
                },
                [3] = {
                    ["aimBone"] = "Projectile_Center",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Projectile_Center",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Projectile_Center",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 1500,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3004/muzzle_cruisemissile.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
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
                        [1] = "Projectile_Left",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Left",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Left",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Left",
                    },
                },
                [5] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Left",
                    },
                },
                [6] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Right",
                    },
                },
                [7] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Right",
                    },
                },
                [8] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Right",
                    },
                },
                [9] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Right",
                    },
                },
                [10] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Right",
                    },
                },
                [11] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Center",
                    },
                },
                [12] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Center",
                    },
                },
                [13] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Center",
                    },
                },
                [14] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Center",
                    },
                },
                [15] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Center",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 1.5,
            ["muzzleSalvoSize"] = 5,
            ["muzzles"] = {
                ["Projectile_Center"] = {
                    ["aimController"] = "Projectile_Center",
                },
                ["Projectile_Left"] = {
                    ["aimController"] = "Projectile_Left",
                },
                ["Projectile_Right"] = {
                    ["aimController"] = "Projectile_Right",
                },
            },
            ["name"] = "CruiseMissile",
            ["projectileLifetime"] = 50,
            ["projectileTemplate"] = "psf0098",
            ["rangeMax"] = 150,
            ["rangeMin"] = 15,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 20,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "69ffed86359f54a0f27d54be653d6da67f84793d44b3f3a5a925fb0656e0b9ea",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissile",
                ["sourceProjectile"] = "/projectiles/CIFMissileTactical02/CIFMissileTactical02_proj.bp",
            },
            ["scoSeaParityTargetGate"] = "TargetAbove",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "CruiseMissile",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Projectile_Front_Left",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Projectile_Front_Left",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 45,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Projectile_Front_Left",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 45,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3004/muzzle_torpedo01.sanvfx",
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
                        [1] = "Projectile_Front_Left",
                        [2] = "Projectile_Front_Right",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Projectile_Front_Left"] = {
                    ["aimController"] = "Projectile_Front_Left",
                },
                ["Projectile_Front_Right"] = {
                    ["aimController"] = "Projectile_Front_Left",
                },
            },
            ["name"] = "Torpedo01",
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0012",
            ["rangeMax"] = 80,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "Torpedo01",
                ["sourceProjectile"] = "/projectiles/CANTorpedoNanite01/CANTorpedoNanite01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "Torpedo01",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Below",
        },
        [3] = {
            ["aimControllers"] = {},
            ["collideFriendly"] = false,
            ["damage"] = 0,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugn3004/muzzle_nukemissile.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Projectile_Center",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {},
            ["name"] = "NukeMissile",
            ["projectileLifetime"] = 10,
            ["projectileTemplate"] = "psf0181",
            ["rangeMax"] = 1024,
            ["rangeMin"] = 128,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 1,
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "4615fbb14dc92dba99f93128d26dc0bb8c10e2d8be169b4e943fb841afa64518",
                ["sourceId"] = "URS0304",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "NukeMissile",
            },
            ["scoFaSourceWeapon"] = {
                ["AboveWaterTargetsOnly"] = true,
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "URSWeapon",
                        ["Cue"] = "URS0304_Missile_Emp",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["Buffs"] = {
                    [1] = {
                        ["Add"] = {
                            ["OnImpact"] = true,
                        },
                        ["AppliedToTarget"] = true,
                        ["BuffType"] = "STUN",
                        ["Duration"] = 3,
                        ["Radius"] = 40,
                        ["TargetAllow"] = "MOBILE",
                        ["TargetDisallow"] = "TECH3,EXPERIMENTAL,COMMAND",
                    },
                },
                ["CollideFriendly"] = false,
                ["CountedProjectile"] = true,
                ["Damage"] = 0,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "EMP Flux Warhead",
                ["EnergyDrainPerSecond"] = 0,
                ["EnergyRequired"] = 0,
                ["FireTargetLayerCapsTable"] = {
                    ["Sub"] = "Land|Water|Seabed",
                    ["Water"] = "Land|Water|Seabed",
                },
                ["FiringTolerance"] = 2,
                ["InitialProjectileStorage"] = 0,
                ["Label"] = "NukeMissile",
                ["ManualFire"] = 1,
                ["MaxProjectileStorage"] = 3,
                ["MaxRadius"] = 1024,
                ["MinRadius"] = 128,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["MuzzleVelocity"] = 0,
                ["NukeInnerRingDamage"] = 70000,
                ["NukeInnerRingRadius"] = 30,
                ["NukeInnerRingTicks"] = 24,
                ["NukeInnerRingTotalTime"] = 0,
                ["NukeOuterRingDamage"] = 500,
                ["NukeOuterRingRadius"] = 40,
                ["NukeOuterRingTicks"] = 20,
                ["NukeOuterRingTotalTime"] = 0,
                ["NukeWeapon"] = true,
                ["ProjectileId"] = "/projectiles/CIFEMPFluxWarhead04/CIFEMPFluxWarhead04_proj.bp",
                ["ProjectilesPerOnFire"] = 1,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Projectile_Center",
                        },
                        ["RackBone"] = "Projectile_Center",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 10,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RateOfFire"] = 1,
                ["TargetCheckInterval"] = 0.5,
                ["TargetRestrictDisallow"] = "UNTARGETABLE",
                ["TurretDualManipulators"] = false,
                ["TurretPitch"] = 0,
                ["TurretPitchRange"] = 0,
                ["TurretPitchSpeed"] = 0,
                ["TurretYaw"] = 0,
                ["TurretYawRange"] = 0,
                ["TurretYawSpeed"] = 0,
                ["Turreted"] = false,
                ["WeaponCategory"] = "Missile",
            },
            ["scoFaSourceWeaponIndex"] = 3,
            ["scoSourceInterceptionLabel"] = "NukeMissile",
            ["scoTacticalOwned"] = true,
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoTactical"] = UnitTemplate["additions"]["scoSourceInterception"]["silo"]
