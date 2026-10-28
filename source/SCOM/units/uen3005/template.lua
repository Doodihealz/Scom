-- uen3005: Tier 3: SP3 - 3000
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["minimumWaterDepth"] = 1.5,
            ["sourceBlueprintSha256"] = "1F2F45F1999DCEB17BDE9B69C0B40AD2F80E55C0343597336A136853C8E371AD",
            ["sourceId"] = "UES0305",
            ["sourceMinimumWaterDepth"] = 1.5,
            ["sourceUniformScale"] = 0.02,
            ["targetId"] = "uen3005",
            ["textureResolution"] = 2048,
        },
        ["scoSeaParityMinimumWaterDepth"] = 1.5,
        ["scoSeaParityPlacementMode"] = "LandOrWater",
        ["seaParitySourceContract"] = {
            ["sourceArchiveSha256"] = "C23A48D6B47043144BAAFC4C7F47B5A470392264F1BBAF962896923D58899C26",
            ["sourceId"] = "UES0305",
            ["targetId"] = "uen3005",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
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
            ["x"] = 1,
            ["y"] = 1.1,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2000,
            ["regen"] = 0,
            ["value"] = 2000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 750,
        ["cost"] = {
            ["alloys"] = 400,
            ["energy"] = 12000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDANavalUnit",
        },
        ["displayName"] = "Tier 3: SP3 - 3000",
        ["icon"] = {
            ["shape"] = "naval1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_naval1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "water",
        ["name"] = "SP3 - 3000",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["requiresWaterPlacement"] = true,
        ["tpId"] = "uen3005",
    },
    ["intel"] = {
        ["radarRadius"] = 0,
        ["sonarRadius"] = 450,
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 4.5,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "Sea",
        },
        ["deceleration"] = 4.5,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 100,
        ["sortOrder"] = 5,
        ["speed"] = 4.5,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "WaterSurface",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [3] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 450,
        },
        [7] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 45,
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
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "EDA",
        [3] = "MOBILE",
        [4] = "NAVAL",
        [5] = "TECH3",
        [6] = "ANTI_SURFACE",
        [7] = "INDIRECT_FIRE",
        [8] = "NEEDMOBILEBUILD",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_INTELLIGENCE",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_MOBILESONAR",
        [16] = "SCFA_NEEDMOBILEBUILD",
        [17] = "SCFA_OVERLAYANTINAVY",
        [18] = "SCFA_OVERLAYSONAR",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SONAR",
        [23] = "SCFA_SORTINTEL",
        [24] = "SCFA_TECH3",
        [25] = "SCFA_UEF",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uen3005/LOD0/uen3005.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.575,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.498,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.6080000000000001,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.762,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.74,
                    ["z"] = 0.18,
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
                ["y"] = 0.3,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
            ["thickness"] = 0.6,
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Projectile01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 180,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Projectile01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Projectile01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["damage"] = 75,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uen3005/muzzle_torpedo01.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 0,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Projectile01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Projectile02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.8,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Projectile01"] = {
                    ["aimController"] = "Projectile01",
                },
                ["Projectile02"] = {
                    ["aimController"] = "Projectile01",
                },
            },
            ["name"] = "Torpedo01",
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0149",
            ["rangeMax"] = 45,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "787fda8530cbcc36e4077cd1f065f5ca11cf18312a1c327f5b1c8fdcff66d1c6",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Torpedo01",
                ["sourceProjectile"] = "/projectiles/TANAnglerTorpedo03/TANAnglerTorpedo03_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "Torpedo01",
            },
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Below",
        },
    },
}
