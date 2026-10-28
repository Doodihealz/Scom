-- ugs2101: Gunther
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["nativeWeaponEconomyChargeSupported"] = false,
            ["sourceCollisionOffset"] = {
                ["x"] = 0,
                ["y"] = -0.25,
                ["z"] = -0.1,
            },
            ["sourceEnergyDrainPerSecond"] = 115,
            ["sourceEnergyRequired"] = 1150,
            ["sourceId"] = "URB2303",
            ["sourceSkirtOffset"] = {
                ["x"] = -0.5,
                ["y"] = -0.5,
            },
            ["targetId"] = "ugs2101",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.25,
            ["z"] = 0.1,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 1.4,
            ["z"] = 0.8,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 3150,
            ["regen"] = 0,
            ["value"] = 3150,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1600,
        ["cost"] = {
            ["alloys"] = 2240,
            ["energy"] = 16000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Gunther",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "indirect",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_indirect.png",
        ["iconUIBuildSortPriority"] = 70,
        ["iconUIType"] = "land",
        ["name"] = "Gunther",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 1116.2,
            ["WaterSurface"] = 1475.2,
        },
        ["tpId"] = "ugs2101",
        ["unitTypeName"] = "GuardT2Arty",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [7] = {
            ["innerRadius"] = 5,
            ["outerRadius"] = 128,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ARTILLERY",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "GUARD",
        [5] = "INDIRECT_FIRE",
        [6] = "STRATEGIC",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_ARTILLERY",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_INDIRECTFIRE",
        [18] = "SCFA_OVERLAYINDIRECTFIRE",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SHOWATTACKRETICLE",
        [23] = "SCFA_SIZE4",
        [24] = "SCFA_SORTSTRATEGIC",
        [25] = "SCFA_STRATEGIC",
        [26] = "SCFA_STRUCTURE",
        [27] = "SCFA_TECH2",
        [28] = "SCFA_VISIBLETORECON",
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vgd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.09999999999999998,
                    ["z"] = -0.060000000000000026,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.0020000000000000018,
                    ["z"] = 0.244,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.14200000000000002,
                    ["z"] = 0.228,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.33799999999999997,
                    ["z"] = -0.060000000000000026,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.30999999999999994,
                    ["z"] = 0.244,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 184,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
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
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -60,
                    ["pitchSpeed"] = 6,
                    ["poseResetTime"] = 14,
                    ["projectileSpeed"] = 26.13,
                    ["reduceMuzzleVelocityToTarget"] = false,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 6,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom1224",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 1750,
            ["damageFriendly"] = true,
            ["damageRadius"] = 4,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugs2101/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 2.5,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 14,
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
            ["projectileLifetime"] = 60,
            ["projectileTemplate"] = "psf0099",
            ["rangeMax"] = 128,
            ["rangeMin"] = 5,
            ["rangeRingType"] = "IndirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 20,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "6a89cda3b080d10dc66547022518fe30a87d337a0ff6ca876fa2ff6f555493a4",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
                ["sourceProjectile"] = "/projectiles/CIFMolecularResonanceShell01/CIFMolecularResonanceShell01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
            ["targetCheckInterval"] = 4,
            ["targetWaterLimits"] = "Above",
        },
    },
}
