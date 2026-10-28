-- uca3701: Seer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca3701/LOD0/uca3701_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "cba5a9c98528d5952da03d8fc0e7bb63ac43bcc713fdb032b9744f9cb70c38b0",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["omniRadius"] = 30,
                },
                ["runtimeSupported"] = {
                    ["radarRadius"] = 96,
                    ["visionRadius"] = 64,
                },
            },
            ["movementCompatibility"] = "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAA0302/UAA0302_unit.bp",
            ["sourceBlueprintSha256"] = "10f13ff89abd5e4a2d56ea9409818b3a9c315f53b5ba30a0d0ea6129bfeaa6c5",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "BUILTBYTIER3FACTORY",
                [4] = "HIGHALTAIR",
                [5] = "INTELLIGENCE",
                [6] = "MOBILE",
                [7] = "OVERLAYOMNI",
                [8] = "OVERLAYRADAR",
                [9] = "PRODUCTSC1",
                [10] = "RADAR",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "TECH3",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 25,
            ["sourceId"] = "UAA0302",
            ["sourceKLift"] = 3,
            ["sourceKLiftDamping"] = 2.5,
            ["sourceLiftFactor"] = 7,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca3701",
            ["weapons"] = {
                [1] = {
                    ["label"] = "DeathImpact",
                    ["muzzleSalvoSize"] = 1,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {},
                    ["rateOfFire"] = 0,
                    ["reloadTime"] = 0,
                    ["sourceCategory"] = "Death",
                    ["sourceProjectile"] = "",
                },
            },
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
                ["y"] = 0.125,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 1.05,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1530",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod5110",
        },
        ["onImpact"] = {
            ["looping"] = false,
            ["name"] = "acod5210",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.125,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 0.25,
            ["z"] = 1.4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1050,
            ["regen"] = 0,
            ["value"] = 1050,
        },
    },
    ["economy"] = {
        ["buildTime"] = 900,
        ["cost"] = {
            ["alloys"] = 195,
            ["energy"] = 7500,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAirUnit",
        },
        ["displayName"] = "Seer",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Seer",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "uca3701",
        ["unitTypeName"] = "Seer",
    },
    ["intel"] = {
        ["radarRadius"] = 96,
        ["visionRadius"] = 64,
    },
    ["movement"] = {
        ["acceleration"] = 30,
        ["air"] = true,
        ["airHover"] = false,
        ["altitudeJitterFactor"] = 1,
        ["bankFactor"] = 1,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["landWhenIdleSeconds"] = 5,
        ["maxBankDegrees"] = 30,
        ["minSpeed"] = 25,
        ["orbitRange"] = 15.915494309189533,
        ["orbitSpeed"] = 25,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 15.915494309189533,
                    ["speed"] = 25,
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
        ["preferredAltitude"] = 25,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 30,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 96,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 64,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 64,
        },
    },
    ["tags"] = {
        [1] = "AIR",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "INTEL",
        [5] = "MOBILE",
        [6] = "RADAR",
        [7] = "TECH3",
        [8] = "SCFA_AEON",
        [9] = "SCFA_AIR",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_HIGHALTAIR",
        [13] = "SCFA_INTELLIGENCE",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYOMNI",
        [16] = "SCFA_OVERLAYRADAR",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RADAR",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
        [23] = "SCOUT",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca3701/LOD0/uca3701.sananimation",
            },
        },
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
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd3101_death_air_small.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
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
                    ["x"] = 0.144,
                    ["y"] = 0.1875,
                    ["z"] = -0.27999999999999997,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.16999999999999998,
                    ["z"] = 0.252,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.195,
                    ["z"] = 0.22399999999999998,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.22999999999999998,
                    ["z"] = -0.27999999999999997,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.225,
                    ["z"] = 0.252,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 105,
            ["lod1distance"] = 275,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.125,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 1.05,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 100,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
