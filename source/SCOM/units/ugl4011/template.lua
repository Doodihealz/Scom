-- ugl4011: Experimental Mobile Rapid-Fire Artillery
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["displayWreckOnDeath"] = true,
        ["faSourceContract"] = {
            ["convertedRackRecoilDistance"] = -2,
            ["convertedRackRecoilReturnSpeed"] = 1.325,
            ["fakeBarrelOrder"] = {
                [1] = "F",
                [2] = "E",
                [3] = "D",
                [4] = "C",
                [5] = "B",
                [6] = "A",
            },
            ["mapping"] = "URL0401 -> ugl4011",
            ["openFps"] = 30,
            ["openFrames"] = 501,
            ["openSeconds"] = 16.66666603088379,
            ["repackTimeoutSeconds"] = 4,
            ["sanctuaryProjectileCollisionFilterRuntime"] = false,
            ["sanctuaryReverseSpeedRuntime"] = false,
            ["sanctuarySelectionThicknessUsesCollisionHeight"] = true,
            ["sanctuarySkirtOffsetRuntime"] = false,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URL0401/URL0401_unit.bp",
            ["sourceBlueprintSha256"] = "c0366fbe9bf45b4c5cb32c9b4618dd97d3756d46e6ff5e3d449d013e89669f74",
            ["sourceCollideFriendly"] = false,
            ["sourceMaxSpeedReverse"] = 0,
            ["sourceOpenAnimation"] = "units/URL0401/URL0401_Aopen.sca",
            ["sourceOpenAnimationSha256"] = "9fd6d8f08446ab7adbeed2923057f43878949cbdc27fc1d05c522e469fbbae6c",
            ["sourceProjectileDestroyOnWater"] = true,
            ["sourceRackRecoilDistance"] = -20,
            ["sourceRackRecoilReturnSpeed"] = 13.25,
            ["sourceRotateOnSpot"] = true,
            ["sourceScript"] = "units/URL0401/URL0401_Script.lua",
            ["sourceScriptSha256"] = "406c68acd2806fae507c68f23b57209a4d8982d512a9bcab3fc95887ba97794e",
            ["sourceSelectionThickness"] = 0.36,
            ["sourceSkirtOffset"] = {
                ["x"] = -1.5,
                ["z"] = -1,
            },
            ["sourceTurnRadius"] = 2,
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Turret_Fake",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 120,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixCybran"] = "1.0.4",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl4011/LOD0/ugl4011_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -2.2028822898864746,
                        ["y"] = -0.057599427250386734,
                        ["z"] = -0.9934694073846604,
                    },
                    ["width"] = 0.492593,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -2.2028822898864746,
                        ["y"] = -0.05759920066421201,
                        ["z"] = 0.7262089349577026,
                    },
                    ["width"] = 0.492593,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -2.2028822898864746,
                        ["y"] = -0.057598978294568844,
                        ["z"] = 2.465070495779223,
                    },
                    ["width"] = 0.492593,
                },
                [4] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 2.110643148422241,
                        ["y"] = -0.05759928941464569,
                        ["z"] = -0.9934694073846836,
                    },
                    ["width"] = 0.492593,
                },
                [5] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 2.110643148422241,
                        ["y"] = -0.057599137334276934,
                        ["z"] = 0.7262089349576919,
                    },
                    ["width"] = 0.492593,
                },
                [6] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 2.110643148422241,
                        ["y"] = -0.05759899319573004,
                        ["z"] = 2.4650704957792255,
                    },
                    ["width"] = 0.492593,
                },
            },
            ["unit"] = "ugl4011",
        },
        ["scoScathisVisibleMuzzleParity"] = {
            ["ballisticMuzzle"] = "Turret_Aim_Barrel_Muzzle",
            ["barrelOrder"] = {
                [1] = "Turret_Barrel_F_Muzzle",
                [2] = "Turret_Barrel_E_Muzzle",
                [3] = "Turret_Barrel_D_Muzzle",
                [4] = "Turret_Barrel_C_Muzzle",
                [5] = "Turret_Barrel_B_Muzzle",
                [6] = "Turret_Barrel_A_Muzzle",
            },
            ["recoilSuffix"] = "_B02",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["size"] = {
                ["x"] = 4,
                ["y"] = 5,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1346",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1041",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 6,
            ["y"] = 2,
            ["z"] = 7,
        },
        ["targetBones"] = {
            [1] = "Root",
            [2] = "Turret_Aim",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 17500,
            ["regen"] = 0,
            ["value"] = 17500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 99900,
        ["cost"] = {
            ["alloys"] = 299700,
            ["energy"] = 5994000,
        },
    },
    ["footprint"] = {
        ["x"] = 5,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardScathis",
        },
        ["displayName"] = "Experimental Mobile Rapid-Fire Artillery",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "indirect",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech3_land1_indirect.png",
        ["iconUIBuildSortPriority"] = 10,
        ["iconUIType"] = "land",
        ["name"] = "Scathis",
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
            ["Land"] = 6983.8,
            ["WaterSurface"] = 3977.8,
        },
        ["tpId"] = "ugl4011",
        ["unitTypeName"] = "GuardT4Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 1,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandLarge",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandLarge",
        },
        ["deceleration"] = 1,
        ["maxBankDegrees"] = 0,
        ["maxReverseDistance"] = 0,
        ["minSpeed"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotateOnSpot"] = true,
        ["rotationSpeed"] = 40,
        ["sortOrder"] = 3,
        ["speed"] = 1,
        ["terrainAlignmentFactor"] = 1,
        ["turnRadius"] = 2,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 100,
            ["outerRadius"] = 4000,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
        },
    },
    ["skirtSize"] = {
        ["x"] = 8,
        ["y"] = 8,
    },
    ["tags"] = {
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "GUARD",
        [4] = "INDIRECT_FIRE",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "TANK",
        [8] = "TECH4",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ARTILLERY",
        [11] = "SCFA_BUILTBYTIER3COMMANDER",
        [12] = "SCFA_BUILTBYTIER3ENGINEER",
        [13] = "SCFA_CYBRAN",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_EXPERIMENTAL",
        [16] = "SCFA_INDIRECTFIRE",
        [17] = "SCFA_LAND",
        [18] = "SCFA_MOBILE",
        [19] = "SCFA_NEEDMOBILEBUILD",
        [20] = "SCFA_OVERLAYINDIRECTFIRE",
        [21] = "SCFA_PRODUCTSC1",
        [22] = "SCFA_RECLAIMABLE",
        [23] = "SCFA_SELECTABLE",
        [24] = "SCFA_SHOWATTACKRETICLE",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["close"] = {
                ["clipName"] = "AnimClose",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl4011/LOD0/ugl4011.sananimation",
            },
            ["open"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl4011/LOD0/ugl4011.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl4011/LOD0/ugl4011.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd0301_death_rdu.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.08,
                    ["y"] = 1.5,
                    ["z"] = -1.4000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.32,
                    ["y"] = 1.3599999999999999,
                    ["z"] = 1.26,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.2000000000000002,
                    ["y"] = 1.56,
                    ["z"] = 1.12,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.08,
                    ["y"] = 1.8399999999999999,
                    ["z"] = -1.4000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.32,
                    ["y"] = 1.8,
                    ["z"] = 1.26,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 175,
            ["lod1distance"] = 550,
        },
        ["selection"] = {
            ["size"] = {
                ["x"] = 4,
                ["y"] = 5,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Aim_Barrel_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Aim_Barrel",
                    ["pitchMax"] = 85,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 30,
                    ["poseResetTime"] = 4,
                    ["projectileSpeed"] = 160,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret_Aim",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["damage"] = 3000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 7,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugl4011/muzzle_gun01.sanvfx",
            },
            ["firingRandomness"] = 0.3,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 4,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Aim_Barrel_Muzzle",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Barrel_F_Muzzle",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Turret_Barrel_E_Muzzle",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Turret_Barrel_D_Muzzle",
                    },
                },
                [5] = {
                    ["muzzles"] = {
                        [1] = "Turret_Barrel_C_Muzzle",
                    },
                },
                [6] = {
                    ["muzzles"] = {
                        [1] = "Turret_Barrel_B_Muzzle",
                    },
                },
                [7] = {
                    ["muzzles"] = {
                        [1] = "Turret_Barrel_A_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Aim_Barrel_Muzzle"] = {
                    ["aimController"] = "Turret_Aim_Barrel_Muzzle",
                },
                ["Turret_Barrel_A_Muzzle"] = {
                    ["aimController"] = "Turret_Aim_Barrel_Muzzle",
                },
                ["Turret_Barrel_B_Muzzle"] = {
                    ["aimController"] = "Turret_Aim_Barrel_Muzzle",
                },
                ["Turret_Barrel_C_Muzzle"] = {
                    ["aimController"] = "Turret_Aim_Barrel_Muzzle",
                },
                ["Turret_Barrel_D_Muzzle"] = {
                    ["aimController"] = "Turret_Aim_Barrel_Muzzle",
                },
                ["Turret_Barrel_E_Muzzle"] = {
                    ["aimController"] = "Turret_Aim_Barrel_Muzzle",
                },
                ["Turret_Barrel_F_Muzzle"] = {
                    ["aimController"] = "Turret_Aim_Barrel_Muzzle",
                },
            },
            ["projectileLifetime"] = 100,
            ["projectileTemplate"] = "psf0096",
            ["rangeMax"] = 4000,
            ["rangeMin"] = 100,
            ["rangeRingType"] = "IndirectFire",
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 1.8867924528301887,
            ["scoFaAboveWaterTargetsOnly"] = true,
            ["scoFaArtilleryShieldBlocks"] = true,
            ["scoFaEnergyChargeForFirstShot"] = false,
            ["scoFaEnergyDrainPerSecond"] = 2000,
            ["scoFaEnergyRequired"] = 2000,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Gun01",
                ["sourceProjectile"] = "/projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp",
            },
            ["scoFaScathis"] = true,
            ["scoFaWeaponRepackSeconds"] = 16.66666603088379,
            ["scoFaWeaponRepackTimeout"] = 4,
            ["scoFaWeaponUnpackLocksMotion"] = true,
            ["scoFaWeaponUnpackSeconds"] = 16.66666603088379,
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Gun01",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
