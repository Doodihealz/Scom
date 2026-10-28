-- uel3101: Demolisher
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprintSha256"] = "bc12b01b06cff5845e22c5511fe72805a8372f88853431dde66f67c7fb7e1bca",
            ["sourceId"] = "UEL0304",
            ["sourceScriptSha256"] = "a97e205d9864ed518d2bb2478bd4320cbdd97f814ac86b15fa50b985aaffda79",
        },
        ["faWeaponDeploy"] = {
            ["deployAnimationKey"] = "deploy",
            ["deploySeconds"] = 1,
            ["keepAnimatorEnabledForAim"] = true,
            ["packAnimationKey"] = "walk",
            ["repackAnimationSupported"] = false,
            ["repackSeconds"] = 0,
            ["sourceWeaponUnpackLocksMotion"] = true,
            ["sourceWeaponUnpacks"] = true,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -0.0026025462150573732,
                [2] = 0.6808685182795573,
                [3] = -0.5511105312405324,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0304",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 91334,
                ["entry"] = "units/UEL0304/UEL0304_lod0.scm",
                ["sha256"] = "b6aa3882640ea03cc3a487662daa8dc100d3923af8450453a55cde81a33aadfa",
            },
        },
        ["scoDemolisherFiring"] = {
            ["sanctuaryProjectile"] = "peu304a",
            ["sourceId"] = "UEL0304",
            ["sourcePitchCenter"] = 30,
            ["sourcePitchRange"] = 45,
            ["sourceProjectile"] = "TIFAntiMatterShells02",
            ["version"] = "1.0.0",
        },
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel3101/LOD0/uel3101_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.296605321764946,
                        ["y"] = -0.0006306978241948919,
                        ["z"] = -0.2725069364555517,
                    },
                    ["width"] = 0.268761,
                },
                [2] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = -0.27268905490636824,
                        ["y"] = -0.0006306017698974383,
                        ["z"] = 0.38564103375892755,
                    },
                    ["width"] = 0.26304,
                },
                [3] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.2726890563964844,
                        ["y"] = -0.0006306017698974383,
                        ["z"] = 0.38564103375892755,
                    },
                    ["width"] = 0.26304,
                },
                [4] = {
                    ["pattern"] = "tread",
                    ["positionOffset"] = {
                        ["x"] = 0.2966053232550621,
                        ["y"] = -0.0006306978241948919,
                        ["z"] = -0.2725069364555517,
                    },
                    ["width"] = 0.268761,
                },
            },
            ["unit"] = "uel3101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.8,
                ["y"] = 2,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1230",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1130",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.5,
            ["z"] = 1.1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 950,
            ["regen"] = 0,
            ["value"] = 950,
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
        ["x"] = 0.7,
        ["y"] = 1.1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAImportedFaLandUnit",
        },
        ["displayName"] = "Demolisher",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "indirect",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_land1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Demolisher",
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
            ["Land"] = 437.9,
            ["WaterSurface"] = 358.3,
        },
        ["tpId"] = "uel3101",
        ["unitTypeName"] = "EDAT3MobileArty",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 2.5,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.5,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 75,
        ["sortOrder"] = 3,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 1,
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
        [3] = "EDA",
        [4] = "INDIRECT_FIRE",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "TECH3",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_ARTILLERY",
        [10] = "SCFA_BUILTBYTIER3FACTORY",
        [11] = "SCFA_INDIRECTFIRE",
        [12] = "SCFA_LAND",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_OVERLAYINDIRECTFIRE",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SHOWATTACKRETICLE",
        [19] = "SCFA_TECH3",
        [20] = "SCFA_UEF",
        [21] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["deploy"] = {
                ["clipName"] = "AnimDeploy",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel3101/LOD0/uel3101.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel3101/LOD0/uel3101.sananimation",
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
                    ["particleName"] = "VFX/Death/ved1301_death_land_large.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.375,
                    ["z"] = -0.22000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.198,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.39,
                    ["z"] = 0.17600000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.22000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.45,
                    ["z"] = 0.198,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 73,
            ["lod1distance"] = 191,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.8,
                ["y"] = 2,
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
                    ["pitchMax"] = 75,
                    ["pitchMin"] = -15,
                    ["pitchSpeed"] = 20,
                    ["poseResetTime"] = 10,
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
                    ["name"] = "aeom3230",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 750,
            ["damageFriendly"] = true,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uel3101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 1.25,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
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
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 20,
            ["projectileTemplate"] = "psf0159",
            ["rangeMax"] = 90,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadProgressBar"] = true,
            ["reloadTime"] = 10,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f5adce36cb2944fa5ba10028e1ae35884bd2104fb0460b973b8267442bc2f28f",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/TIFAntiMatterShells02/TIFAntiMatterShells02_proj.bp",
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
