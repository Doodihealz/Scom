-- uea1701: Tier 1: Air Scout
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["collision"] = {
                ["centerOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
                ["size"] = {
                    ["x"] = 0.4,
                    ["y"] = 0.15,
                    ["z"] = 0.6,
                },
            },
            ["deathImpact"] = {
                ["aboveWaterTargetsOnly"] = true,
                ["damage"] = 10,
                ["damageFriendly"] = true,
                ["damageRadius"] = 1,
                ["damageType"] = "Normal",
                ["firingTolerance"] = 2,
                ["label"] = "DeathImpact",
                ["weaponCategory"] = "Death",
            },
            ["footprint"] = {
                ["sourceMaxSlope"] = 0.25,
                ["x"] = 1,
                ["y"] = 1,
            },
            ["movement"] = {
                ["nativeBankFactor"] = 1,
                ["nativeOrbitRange"] = 9.740282517223996,
                ["nativeOrbitSpeed"] = 17,
                ["sourceAutoLandTime"] = 1,
                ["sourceBankFactor"] = 2,
                ["sourceBankForward"] = false,
                ["sourceBankingSlope"] = 0.5,
                ["sourceCanFly"] = true,
                ["sourceCombatTurnSpeed"] = 1,
                ["sourceElevation"] = 18,
                ["sourceEngageDistance"] = 50,
                ["sourceFuelRechargeRate"] = 5,
                ["sourceFuelUseTime"] = 500,
                ["sourceGroundCollisionOffset"] = 1.6,
                ["sourceKLift"] = 3,
                ["sourceKLiftDamping"] = 2.5,
                ["sourceKMove"] = 1,
                ["sourceKMoveDamping"] = 1,
                ["sourceKRoll"] = 2,
                ["sourceKRollDamping"] = 1,
                ["sourceKTurn"] = 1,
                ["sourceKTurnDamping"] = 1.5,
                ["sourceLiftFactor"] = 7,
                ["sourceMaxAcceleration"] = 10,
                ["sourceMaxAirspeed"] = 20,
                ["sourceMaxSteerForce"] = 100,
                ["sourceMinAirspeed"] = 17,
                ["sourceMinSpeedPercent"] = 0.85,
                ["sourceMotionType"] = "RULEUMT_Air",
                ["sourcePhysicsMaxSpeed"] = 10,
                ["sourceStartTurnDistance"] = 5,
                ["sourceTightTurnMultiplier"] = 1.1,
                ["sourceTurnRadius"] = 100,
                ["sourceTurnRate"] = 100,
                ["sourceTurnSpeed"] = 0.8,
                ["sourceWinged"] = true,
            },
            ["selection"] = {
                ["size"] = {
                    ["x"] = 0.36,
                    ["y"] = 0.5,
                },
                ["thickness"] = 0.8,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEA0101/UEA0101_unit.bp",
            ["sourceBlueprintSha256"] = "39b9fbfadab9d5aefcb1e624e69a0fa71b806f887576145198b6971fc1976824",
            ["sourceCategories"] = {
                [1] = "PRODUCTSC1",
                [2] = "SELECTABLE",
                [3] = "BUILTBYTIER1FACTORY",
                [4] = "BUILTBYTIER2FACTORY",
                [5] = "BUILTBYTIER3FACTORY",
                [6] = "MOBILE",
                [7] = "AIR",
                [8] = "HIGHALTAIR",
                [9] = "TECH1",
                [10] = "INTELLIGENCE",
                [11] = "SCOUT",
                [12] = "VISIBLETORECON",
                [13] = "RECLAIMABLE",
                [14] = "UEF",
            },
            ["sourceId"] = "UEA0101",
            ["sourceSizeSphere"] = 1.6,
            ["targetId"] = "uea1701",
        },
        ["scoCargo"] = {
            ["airPortable"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["portable"] = false,
            ["slots"] = {},
            ["unfoldDuration"] = 0,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.36,
                ["y"] = 0.5,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aelu1512",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod5110",
        },
        ["onImpact"] = {
            ["looping"] = false,
            ["name"] = "aeod5210",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.4,
            ["y"] = 0.15,
            ["z"] = 0.6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 35,
            ["regen"] = 0,
            ["value"] = 35,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 40,
            ["energy"] = 1600,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAAirUnit",
        },
        ["displayName"] = "Tier 1: Air Scout",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "intel",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_intel.png",
        ["iconUIBuildSortPriority"] = 100,
        ["iconUIType"] = "air",
        ["name"] = "Magpie",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uea1701",
        ["unitTypeName"] = "EDAT1AirScout",
    },
    ["intel"] = {
        ["visionRadius"] = 42,
    },
    ["movement"] = {
        ["acceleration"] = 10,
        ["air"] = true,
        ["airHover"] = false,
        ["altitudeJitterFactor"] = 1,
        ["bankFactor"] = 1,
        ["bankHalfLife"] = 0.075647079736603,
        ["chassisRotationHalfLife"] = 0.1,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["landWhenIdleSeconds"] = 1,
        ["maxBankDegrees"] = 30,
        ["minSpeed"] = 17,
        ["orbitRange"] = 9.740282517223996,
        ["orbitSpeed"] = 17,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 9.740282517223996,
                    ["speed"] = 17,
                },
                ["mode"] = "Circle",
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
            ["cruise"] = {
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
            ["strafe"] = {
                ["mode"] = "Strafe",
                ["strafe"] = {
                    ["matchTargetSpeed"] = true,
                    ["runOutLength"] = 14.324,
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
        },
        ["preferredAltitude"] = 18,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 100,
        ["sortOrder"] = 2,
        ["speed"] = 20,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 42,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 42,
        },
    },
    ["tags"] = {
        [1] = "AIR",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "EDA",
        [6] = "INTEL",
        [7] = "MOBILE",
        [8] = "SCOUT",
        [9] = "TECH1",
        [10] = "SCFA_AIR",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER1FACTORY",
        [13] = "SCFA_BUILTBYTIER2FACTORY",
        [14] = "SCFA_BUILTBYTIER3FACTORY",
        [15] = "SCFA_HIGHALTAIR",
        [16] = "SCFA_INTELLIGENCE",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_PRODUCTSC1",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SCOUT",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_TECH1",
        [23] = "SCFA_UEF",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
                    ["particleName"] = "VFX/SCOM/Death/ved3101_death_air_small.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/ved1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.072,
                    ["y"] = 0.0375,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.08800000000000001,
                    ["y"] = 0.027,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.08000000000000002,
                    ["y"] = 0.042,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.072,
                    ["y"] = 0.063,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.08800000000000001,
                    ["y"] = 0.06,
                    ["z"] = 0.108,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 107,
            ["lod1distance"] = 279,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.36,
                ["y"] = 0.5,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 10,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
