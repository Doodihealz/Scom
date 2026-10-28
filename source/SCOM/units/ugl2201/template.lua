-- ugl2201: Tier 2: Mobile AA Flak Artillery
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["limitations"] = {
                ["electronBurstCloudEmitterGraph"] = false,
                ["flakDetonateAboveTargetHeight"] = false,
                ["projectileDestroyOnWaterRuntime"] = false,
                ["sanctuaryProjectileVisual"] = "Guard medium-AA compatibility trail/impact",
                ["sourceAudioBanks"] = false,
                ["sourceGroundKickupAndScrollingTreads"] = false,
                ["sourceRackRecoilDistance"] = -0.5,
                ["sourceRackRecoilRuntime"] = false,
            },
            ["mapping"] = "URL0205 -> ugl2201",
            ["movementAnimation"] = "source has no active SCA; engine locomotion keeps the packed Rest pose",
            ["sourceAnimationWalk"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URL0205/URL0205_unit.bp",
            ["sourceBlueprintSha256"] = "53fb5ae5cadc1f36af4b1190c29dda6eaf30318806b13e3688ec427ae6bf7436",
            ["sourceMaxSpeedReverse"] = 0,
            ["sourceModel"] = "units/URL0205/URL0205_lod0.scm",
            ["sourceModelSha256"] = "9051cd745f341f77f62da2bd9e5d1c8a4d87e77344a738a894350f37bfe47c0b",
            ["sourceProjectile"] = "CAABurstCloud01",
            ["sourceProjectileBlueprintSha256"] = "a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4",
            ["sourceProjectileScriptSha256"] = "c40d3c20d99e4bf9380bb68009558bf0da7f3a516e327305cbd41e6f3fa314bc",
            ["sourceRig"] = {
                ["boneCount"] = 10,
                ["indices"] = 1770,
                ["vertices"] = 1034,
            },
            ["sourceRotateOnSpot"] = true,
            ["sourceScript"] = "units/URL0205/URL0205_script.lua",
            ["sourceScriptSha256"] = "e3118736b13e505928e8a9572b73be896f747b5d4d4b429adfa4bc60c7fc0496",
            ["sourceSelectionThickness"] = 0.6,
            ["sourceTurnRadius"] = 0,
            ["sourceUniformScale"] = 0.2,
            ["substitution"] = "Cybran mobile anti-air -> Guard/Cybran mobile anti-air",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -3.775048895704458e-09,
                [2] = 0.5948051794535949,
                [3] = -0.14623381769186597,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0205",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 75273,
                ["entry"] = "units/URL0205/URL0205_lod0.scm",
                ["sha256"] = "9051cd745f341f77f62da2bd9e5d1c8a4d87e77344a738a894350f37bfe47c0b",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl2201/LOD0/ugl2201_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22542737424373627,
                        ["y"] = -0.015568573984639674,
                        ["z"] = -0.37999996280464593,
                    },
                    ["width"] = 0.204523,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22542737424373627,
                        ["y"] = -0.01556852001948847,
                        ["z"] = -0.13999998307023084,
                    },
                    ["width"] = 0.204523,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22542737424373627,
                        ["y"] = -0.015568466054325962,
                        ["z"] = 0.10000006371940962,
                    },
                    ["width"] = 0.204523,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.22542737424373627,
                        ["y"] = -0.015568573984644698,
                        ["z"] = -0.3799999926069683,
                    },
                    ["width"] = 0.204523,
                },
                [5] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.22542737424373627,
                        ["y"] = -0.01556852001948847,
                        ["z"] = -0.13999998307023084,
                    },
                    ["width"] = 0.204523,
                },
                [6] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.22542737424373627,
                        ["y"] = -0.015568466054325962,
                        ["z"] = 0.10000006371940962,
                    },
                    ["width"] = 0.204523,
                },
            },
            ["unit"] = "ugl2201",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.65,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.3,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.65,
            ["y"] = 0.6,
            ["z"] = 0.9,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1000,
            ["regen"] = 0,
            ["value"] = 1000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 800,
        },
    },
    ["footprint"] = {
        ["x"] = 0.65,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardLandUnit",
        },
        ["displayName"] = "Tier 2: Mobile AA Flak Artillery",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "aa",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_antiAir.png",
        ["iconUIBuildSortPriority"] = 50,
        ["iconUIType"] = "land",
        ["name"] = "Banger",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 1595.1,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "ugl2201",
        ["unitTypeName"] = "GuardT2MAA",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 2.9,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.9,
        ["maxBankDegrees"] = 0,
        ["maxReverseDistance"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotateOnSpot"] = true,
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 5,
        ["speed"] = 2.9,
        ["terrainAlignmentFactor"] = 1,
        ["turnRadius"] = 0,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 40,
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
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "GUARD",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "TECH2",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ANTIAIR",
        [10] = "SCFA_BUILTBYTIER2FACTORY",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_CYBRAN",
        [13] = "SCFA_LAND",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYANTIAIR",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_TECH2",
        [20] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
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
                    ["particleName"] = "VFX/Death/vgd1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.44999999999999996,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.408,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13,
                    ["y"] = 0.46799999999999997,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.11699999999999999,
                    ["y"] = 0.552,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.14300000000000002,
                    ["y"] = 0.54,
                    ["z"] = 0.162,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 130,
            ["lod1distance"] = 350,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.05,
            },
            ["size"] = {
                ["x"] = 0.5,
                ["y"] = 0.65,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 35,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Barrel",
                    ["pitchMax"] = 75,
                    ["pitchMin"] = -5,
                    ["pitchSpeed"] = 180,
                    ["poseResetTime"] = 0,
                    ["projectileSpeed"] = 20,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 180,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom1221",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 90,
            ["damageFriendly"] = false,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugl2201/muzzle_aagun.sanvfx",
            },
            ["firingRandomness"] = 2.5,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Muzzle01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Left_Muzzle01",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Right_Muzzle02",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Left_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Left_Muzzle01"] = {
                    ["aimController"] = "Right_Muzzle01",
                },
                ["Left_Muzzle02"] = {
                    ["aimController"] = "Right_Muzzle01",
                },
                ["Right_Muzzle01"] = {
                    ["aimController"] = "Right_Muzzle01",
                },
                ["Right_Muzzle02"] = {
                    ["aimController"] = "Right_Muzzle01",
                },
            },
            ["projectileLifetime"] = 6.25,
            ["projectileTemplate"] = "psf0081",
            ["rangeMax"] = 40,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.4,
            ["reloadTime"] = 0.625,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "a67bd4f98381453ecd65897dc7d40feb7f8c1005f669b67e3f20e2162362bff4",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
                ["sourceProjectile"] = "/projectiles/CAABurstCloud01/CAABurstCloud01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AAGun",
            },
            ["targetCheckInterval"] = 0.3,
            ["targetWaterLimits"] = "Above",
        },
    },
}
