-- ugl3101: Tier 3: Mobile Heavy Artillery
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["limitations"] = {
                ["forceAndFireDamageRings"] = false,
                ["impactLightDecalCameraShakeAndFollow"] = false,
                ["muzzleVelocityReduceDistance"] = 85,
                ["projectileDestroyOnWaterRuntime"] = false,
                ["sanctuaryProjectileVisual"] = "Guard proton-artillery compatibility trail/impact",
                ["sanctuaryVelocityReduction"] = "boolean adapter has no distance threshold",
                ["sourceAudioBanks"] = false,
                ["sourceGroundKickupAndScrollingTreads"] = false,
                ["sourceRackRecoilDistance"] = -1,
                ["sourceRackRecoilRuntime"] = false,
            },
            ["mapping"] = "URL0304 -> ugl3101",
            ["sourceAnimation"] = "units/URL0304/URL0304_Aactivate.sca",
            ["sourceAnimationFps"] = 10,
            ["sourceAnimationFrames"] = 17,
            ["sourceAnimationSeconds"] = 1.600000023841858,
            ["sourceAnimationSha256"] = "008bd0f7a56bf9b513fca03e42d079654f571e6572beaee9c5432a8c4cb58657",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URL0304/URL0304_unit.bp",
            ["sourceBlueprintSha256"] = "10aa240dba2bf0bffd00589cfeebf1facd49eebaf9f799b5123a435e7aff161b",
            ["sourceClose"] = "exact time reversal of the active Aactivate source clip",
            ["sourceMaxSpeedReverse"] = 0,
            ["sourceModel"] = "units/URL0304/URL0304_lod0.scm",
            ["sourceModelSha256"] = "4fe449b72ead76d0e6c3d286d05eb841ff58c2a08a8e531e799a67dc836e618b",
            ["sourceProjectile"] = "CIFArtilleryProton01",
            ["sourceProjectileBlueprintSha256"] = "e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e",
            ["sourceProjectileScriptSha256"] = "98a19bd78f1a61dc4c2f3f9e2c63a6cb27aadb6cbb352dbe6cf430d3483ee0ef",
            ["sourceRig"] = {
                ["boneCount"] = 11,
                ["indices"] = 2040,
                ["vertices"] = 896,
            },
            ["sourceRotateOnSpot"] = true,
            ["sourceScript"] = "units/URL0304/URL0304_Script.lua",
            ["sourceScriptSha256"] = "57adaddea1cfc1cdae48cd7f1f003446b4552ce8890d45a62b3eea886ed0bbf9",
            ["sourceSelectionThickness"] = 0.55,
            ["sourceTurnRadius"] = 0,
            ["sourceUniformScale"] = 0.35,
            ["sourceWeaponRepackTimeout"] = 0,
            ["sourceWeaponUnpackLocksMotion"] = true,
            ["sourceWeaponUnpacks"] = true,
            ["substitution"] = "Cybran mobile artillery -> Guard/Cybran mobile artillery",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -2.2968649864196775e-05,
                [2] = 0.5768957351811185,
                [3] = 0.0004905820943847749,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0304",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 66600,
                ["entry"] = "units/URL0304/URL0304_lod0.scm",
                ["sha256"] = "4fe449b72ead76d0e6c3d286d05eb841ff58c2a08a8e531e799a67dc836e618b",
            },
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/ugl3101/LOD0/ugl3101_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.5139153003692627,
                        ["y"] = 0.0018922480530181689,
                        ["z"] = 0.0061645802645632864,
                    },
                    ["width"] = 0.220181,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.5137857794761658,
                        ["y"] = 0.0018922480530181689,
                        ["z"] = 0.0061645802645632864,
                    },
                    ["width"] = 0.220181,
                },
            },
            ["unit"] = "ugl3101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = -0.15,
            },
            ["size"] = {
                ["x"] = 0.8,
                ["y"] = 0.8,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.2,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.2,
            ["y"] = 0.4,
            ["z"] = 0.8,
        },
        ["targetBones"] = {
            [1] = "Root",
            [2] = "Turret",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 850,
            ["regen"] = 0,
            ["value"] = 850,
        },
    },
    ["economy"] = {
        ["buildTime"] = 4800,
        ["cost"] = {
            ["alloys"] = 800,
            ["energy"] = 8000,
        },
    },
    ["footprint"] = {
        ["x"] = 1.2,
        ["y"] = 0.8,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardTrebuchet",
        },
        ["displayName"] = "Tier 3: Mobile Heavy Artillery",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "indirect",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_land1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Trebuchet",
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
            ["Land"] = 992.7,
            ["WaterSurface"] = 907.5,
        },
        ["tpId"] = "ugl3101",
        ["unitTypeName"] = "GuardT3MobileDroneCarrier",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 2.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.5,
        ["maxBankDegrees"] = 0,
        ["maxReverseDistance"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotateOnSpot"] = true,
        ["rotationSpeed"] = 75,
        ["sortOrder"] = 3,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 1,
        ["turnRadius"] = 0,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 90,
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
    ["tags"] = {
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "GUARD",
        [4] = "INDIRECT_FIRE",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "TECH3",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ARTILLERY",
        [10] = "SCFA_BUILTBYTIER3FACTORY",
        [11] = "SCFA_CYBRAN",
        [12] = "SCFA_INDIRECTFIRE",
        [13] = "SCFA_LAND",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYINDIRECTFIRE",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SHOWATTACKRETICLE",
        [20] = "SCFA_TECH3",
        [21] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["close"] = {
                ["clipName"] = "AnimClose",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl3101/LOD0/ugl3101.sananimation",
            },
            ["deploy"] = {
                ["clipName"] = "AnimActivate",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl3101/LOD0/ugl3101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl3101/LOD0/ugl3101.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd1301_death_land_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.216,
                    ["y"] = 0.30000000000000004,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.272,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.24,
                    ["y"] = 0.31200000000000006,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.216,
                    ["y"] = 0.368,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.264,
                    ["y"] = 0.36000000000000004,
                    ["z"] = 0.144,
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
                ["z"] = -0.15,
            },
            ["size"] = {
                ["x"] = 0.8,
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
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 30,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 20,
                    ["poseResetTime"] = 0,
                    ["projectileSpeed"] = 22,
                    ["reduceMuzzleVelocityToTarget"] = true,
                    ["solverType"] = "HighArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 30,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom3230",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 450,
            ["damageFriendly"] = true,
            ["damageRadius"] = 7,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugl3101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 2,
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
            ["projectileTemplate"] = "psf0096",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 6.666666666666667,
            ["scoFaEggAboveWaterTargetsOnly"] = true,
            ["scoFaEggArtilleryShieldBlocks"] = true,
            ["scoFaEggTrebuchet"] = true,
            ["scoFaEggTrebuchetDeploySeconds"] = 1.600000023841858,
            ["scoFaEggTrebuchetRepackSeconds"] = 1.600000023841858,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "e6c467c6c23fc19d1fb41b9196f4e65d52b9202430bbd16343a5bde3121b246e",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/CIFArtilleryProton01/CIFArtilleryProton01_proj.bp",
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
