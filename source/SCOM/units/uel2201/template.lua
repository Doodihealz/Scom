-- uel2201: Flapjack
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprintSha256"] = "d83f35f34c34b6ae4a8a58960b712a94858871dd260bac818253e85364cdbbd6",
            ["sourceId"] = "UEL0111",
            ["sourceMuzzleVelocity"] = 3,
            ["sourceProjectileMaxSpeed"] = 12,
            ["sourceScriptSha256"] = "cdd5e6cc21ac9514e3c9936782fa2a3aa10e53a8dc54dd1fb55b512a7466ec26",
        },
        ["faWeaponDeploy"] = {
            ["deployAnimationKey"] = "deploy",
            ["deploySeconds"] = 3.3333332538604736,
            ["packAnimationKey"] = "walk",
            ["repackAnimationSupported"] = false,
            ["repackSeconds"] = 1,
            ["sourceWeaponUnpackLocksMotion"] = false,
            ["sourceWeaponUnpacks"] = true,
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -5.566053913806021e-14,
                [2] = 0.5789127220087161,
                [3] = 0.17055715581760586,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UEL0111",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 76740,
                ["entry"] = "units/UEL0111/UEL0111_LOD0.scm",
                ["sha256"] = "d73a4006d9ea62e4215c00c4a461bfc400e52e57f9c88d6f9587e4525c69e3da",
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["scoGroundTracks"] = {
            ["boneName"] = "Root",
            ["modelPath"] = "Units/uel2201/LOD0/uel2201_lod0.sanmodel",
            ["trails"] = {
                [1] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22983957827091217,
                        ["y"] = 0.0011786781274958408,
                        ["z"] = -0.3340427236173985,
                    },
                    ["width"] = 0.087392,
                },
                [2] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22983956336975098,
                        ["y"] = 0.0011787037551806503,
                        ["z"] = -0.11906214743002784,
                    },
                    ["width"] = 0.087392,
                },
                [3] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22983954846858978,
                        ["y"] = 0.0011786759512904762,
                        ["z"] = -0.5476105318878542,
                    },
                    ["width"] = 0.087392,
                },
                [4] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22983954846858978,
                        ["y"] = 0.0011787561328666432,
                        ["z"] = 0.5234386517192452,
                    },
                    ["width"] = 0.087392,
                },
                [5] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = -0.22983954101800919,
                        ["y"] = 0.0011787548759135073,
                        ["z"] = 0.3097695900584773,
                    },
                    ["width"] = 0.087392,
                },
                [6] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.23069557547569275,
                        ["y"] = 0.0011789618673208832,
                        ["z"] = -0.5476105318878883,
                    },
                    ["width"] = 0.087392,
                },
                [7] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.23069557547569275,
                        ["y"] = 0.001178987326590613,
                        ["z"] = -0.33404272361743537,
                    },
                    ["width"] = 0.087392,
                },
                [8] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.23069557547569275,
                        ["y"] = 0.0011789896712123896,
                        ["z"] = -0.11906213625419103,
                    },
                    ["width"] = 0.087392,
                },
                [9] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.23069560527801514,
                        ["y"] = 0.0011790420489023793,
                        ["z"] = 0.5234386964226947,
                    },
                    ["width"] = 0.087392,
                },
                [10] = {
                    ["pattern"] = "wheel",
                    ["positionOffset"] = {
                        ["x"] = 0.23069561272859573,
                        ["y"] = 0.0011790407919421379,
                        ["z"] = 0.30976957515728204,
                    },
                    ["width"] = 0.087392,
                },
            },
            ["unit"] = "uel2201",
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
            ["name"] = "aelu1220",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod1120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.3,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.6,
            ["z"] = 1.3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 825,
            ["regen"] = 0,
            ["value"] = 825,
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
        ["x"] = 0.6,
        ["y"] = 1.3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAImportedFaLandUnit",
        },
        ["displayName"] = "Flapjack",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "aa",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_antiAir.png",
        ["iconUIBuildSortPriority"] = 50,
        ["iconUIType"] = "land",
        ["name"] = "Flapjack",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 302.4,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uel2201",
        ["unitTypeName"] = "EDAT2MAA",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
    },
    ["movement"] = {
        ["acceleration"] = 2.8,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 2.8,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 5,
        ["speed"] = 2.8,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "TracksLand",
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 5,
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
        [1] = "ANTI_AIR",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "EDA",
        [5] = "LAND",
        [6] = "MOBILE",
        [7] = "TECH2",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER2FACTORY",
        [10] = "SCFA_BUILTBYTIER3FACTORY",
        [11] = "SCFA_INDIRECTFIRE",
        [12] = "SCFA_LAND",
        [13] = "SCFA_MOBILE",
        [14] = "SCFA_OVERLAYINDIRECTFIRE",
        [15] = "SCFA_PRODUCTSC1",
        [16] = "SCFA_RECLAIMABLE",
        [17] = "SCFA_SELECTABLE",
        [18] = "SCFA_SILO",
        [19] = "SCFA_TECH2",
        [20] = "SCFA_UEF",
        [21] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["deploy"] = {
                ["clipName"] = "AnimDeploy",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel2201/LOD0/uel2201.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uel2201/LOD0/uel2201.sananimation",
            },
        },
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
                    ["particleName"] = "VFX/Death/ved1201_death_land_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.44999999999999996,
                    ["z"] = -0.26,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.408,
                    ["z"] = 0.23399999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.46799999999999997,
                    ["z"] = 0.20800000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.552,
                    ["z"] = -0.26,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.54,
                    ["z"] = 0.23399999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 174,
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
                    ["aimBone"] = "Target_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Target_Pitch",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 1,
                    ["projectileSpeed"] = 3,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Target_Yaw",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "aeom5221",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 300,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0.5,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uel2201/muzzle_missileweapon.sanvfx",
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
            ["muzzleGroupChargeDelay"] = 0.5,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Target_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["projectileLifetime"] = 20,
            ["projectileTemplate"] = "psf0174",
            ["rangeMax"] = 60,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "1d66eea3f9a50a802fc2ae554f067738495da05e69d1828ab2e98fe0a421be7c",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileWeapon",
                ["sourceProjectile"] = "/projectiles/TIFMissileCruise03/TIFMissileCruise03_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MissileWeapon",
            },
            ["targetCheckInterval"] = 2,
            ["targetWaterLimits"] = "Above",
        },
    },
}
