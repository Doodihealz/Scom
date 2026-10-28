-- uca1502: Chariot
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca1502/LOD0/uca1502_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "b807d3966a3bb8e8905a76bc4542e6b3d62788634b4010942a986b3316b913f3",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 32,
                },
            },
            ["movementCompatibility"] = "Sanctuary's native preferred-altitude controller applies exact source Elevation; LiftFactor and the FA lift curve remain provenance. Missing Physics.MaxAcceleration uses Sanctuary's functional MaxAirspeed acceleration fallback; FA KMove/KMoveDamping remain in the hash-pinned source blueprint. Missing Physics.TurnRate uses Sanctuary's functional 90-degree/second aircraft fallback; FA Air.TurnSpeed remains in the hash-pinned source blueprint.",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 4,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAA0107/UAA0107_unit.bp",
            ["sourceBlueprintSha256"] = "e9634d62ac929cfc3712c3b776d0958c53f569046039a9c8eb8e2a5161361a6d",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "CANNOTUSEAIRSTAGING",
                [4] = "CANTRANSPORTCOMMANDER",
                [5] = "MOBILE",
                [6] = "PRODUCTSC1",
                [7] = "RECLAIMABLE",
                [8] = "SELECTABLE",
                [9] = "TECH1",
                [10] = "TRANSPORTATION",
                [11] = "TRANSPORTBUILTBYTIER1FACTORY",
                [12] = "TRANSPORTBUILTBYTIER2FACTORY",
                [13] = "TRANSPORTBUILTBYTIER3FACTORY",
                [14] = "TRANSPORTFOCUS",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 8,
            ["sourceId"] = "UAA0107",
            ["sourceKLift"] = 2,
            ["sourceKLiftDamping"] = 2,
            ["sourceLiftFactor"] = 8,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca1502",
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
            ["attachmentReference"] = "entity origin fallback: source model has no AttachPoint",
            ["canCarryCommander"] = true,
            ["canFire"] = true,
            ["cargoClass"] = 10,
            ["commander"] = false,
            ["genericUpTo"] = 0,
            ["portable"] = false,
            ["slots"] = {
                [1] = {
                    ["bone"] = "Attachpoint_Small_01",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 1,
                    },
                    ["position"] = {
                        [1] = 0.24579988462479296,
                        [2] = 0.01583295373692851,
                        [3] = 0.6236719228475168,
                    },
                },
                [2] = {
                    ["bone"] = "Attachpoint_Small_02",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 2,
                    },
                    ["position"] = {
                        [1] = -0.24580008047074497,
                        [2] = 0.01583288136427281,
                        [3] = 0.6236717164864207,
                    },
                },
                [3] = {
                    ["bone"] = "Attachpoint_Med_01",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 1,
                        [2] = 2,
                    },
                    ["position"] = {
                        [1] = -1.0733572213419084e-07,
                        [2] = 0.015832891590446645,
                        [3] = 0.653941394785984,
                    },
                },
                [4] = {
                    ["bone"] = "Attachpoint_Small_06",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 4,
                    },
                    ["position"] = {
                        [1] = -0.739749915263757,
                        [2] = 0.015832622394432505,
                        [3] = -0.21425024625404565,
                    },
                },
                [5] = {
                    ["bone"] = "Attachpoint_Med_03",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 4,
                        [2] = 6,
                    },
                    ["position"] = {
                        [1] = -0.6415499692920131,
                        [2] = 0.0158325845611096,
                        [3] = -0.44160027702296234,
                    },
                },
                [6] = {
                    ["bone"] = "Attachpoint_Small_05",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 6,
                    },
                    ["position"] = {
                        [1] = -0.49119985728240884,
                        [2] = 0.015832597508558758,
                        [3] = -0.6384001800253287,
                    },
                },
                [7] = {
                    ["bone"] = "Attachpoint_Small_04",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 7,
                    },
                    ["position"] = {
                        [1] = 0.49118538475073037,
                        [2] = 0.015832599561272722,
                        [3] = -0.6383849816342834,
                    },
                },
                [8] = {
                    ["bone"] = "Attachpoint_Small_03",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 8,
                    },
                    ["position"] = {
                        [1] = 0.7397315031120274,
                        [2] = 0.015832717581965052,
                        [3] = -0.21424413728884306,
                    },
                },
                [9] = {
                    ["bone"] = "Attachpoint_Med_02",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 7,
                        [2] = 8,
                    },
                    ["position"] = {
                        [1] = 0.6415741911832313,
                        [2] = 0.015832724032866924,
                        [3] = -0.44161845100847996,
                    },
                },
                [10] = {
                    ["bone"] = "Attachpoint_Lrg_01",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 2,
                        [2] = 1,
                        [3] = 8,
                        [4] = 4,
                    },
                    ["position"] = {
                        [1] = 2.2453581180386097e-09,
                        [2] = -0.029741093516361613,
                        [3] = 9.276737998252244e-08,
                    },
                },
            },
            ["sourceId"] = "UAA0107",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 380548,
                ["entry"] = "units/UAA0107/UAA0107_lod0.scm",
                ["sha256"] = "f6238b481ca72b22bef8e7de87f1e3426f112c4f0fd2aec948b69867661b9514",
            },
            ["sourceTransport"] = {
                ["AirClass"] = true,
                ["Class2AttachSize"] = 2,
                ["Class3AttachSize"] = 4,
                ["TransportClass"] = 10,
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.9,
                ["y"] = 0.9,
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
            ["y"] = -0.75,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 3,
            ["y"] = 2.5,
            ["z"] = 3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 80,
            ["energy"] = 1600,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAirUnit",
        },
        ["displayName"] = "Chariot",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Chariot",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["Transport"] = true,
        },
        ["tpId"] = "uca1502",
        ["unitTypeName"] = "Chariot",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 10,
        ["air"] = true,
        ["airHover"] = true,
        ["altitudeJitterFactor"] = 1,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["landWhenIdleSeconds"] = 5,
        ["maxBankDegrees"] = 0,
        ["minSpeed"] = 0,
        ["orbitRange"] = 6.366197723675814,
        ["orbitSpeed"] = 10,
        ["patternBySituation"] = {
            ["assist"] = "orbit",
            ["attack"] = "orbit",
            ["hold"] = "idle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["cruise"] = {
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                },
            },
            ["idle"] = {
                ["mode"] = "Orbit",
                ["orbit"] = {
                    ["acceleration"] = 2.167,
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["facing"] = "hold",
                    ["maxSpeed"] = 1.3,
                    ["radius"] = {
                        ["x"] = 0,
                        ["y"] = 0.15,
                    },
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                    ["syncToLateralPhase"] = true,
                },
            },
            ["orbit"] = {
                ["mode"] = "Orbit",
                ["orbit"] = {
                    ["acceleration"] = 2.167,
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["facing"] = "center",
                    ["maxSpeed"] = 1.3,
                    ["radius"] = {
                        ["x"] = 15,
                        ["y"] = 20,
                    },
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 1.5,
                        ["y"] = 4.5,
                    },
                    ["offset"] = {
                        ["x"] = -1.275,
                        ["y"] = 1.275,
                    },
                    ["syncToLateralPhase"] = true,
                },
            },
        },
        ["preferredAltitude"] = 8,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 10,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Gunship",
    },
    ["ranges"] = {
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
        [1] = "AIR",
        [2] = "BUILDABLE_BY_T1_FACTORY",
        [3] = "BUILDABLE_BY_T2_FACTORY",
        [4] = "BUILDABLE_BY_T3_FACTORY",
        [5] = "CHOSEN",
        [6] = "GUNSHIP",
        [7] = "MOBILE",
        [8] = "TECH1",
        [9] = "TRANSPORT",
        [10] = "SCFA_AEON",
        [11] = "SCFA_AIR",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_CANNOTUSEAIRSTAGING",
        [14] = "SCFA_CANTRANSPORTCOMMANDER",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_TECH1",
        [20] = "SCFA_TRANSPORTATION",
        [21] = "SCFA_TRANSPORTBUILTBYTIER1FACTORY",
        [22] = "SCFA_TRANSPORTBUILTBYTIER2FACTORY",
        [23] = "SCFA_TRANSPORTBUILTBYTIER3FACTORY",
        [24] = "SCFA_TRANSPORTFOCUS",
        [25] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca1502/LOD0/uca1502.sananimation",
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
                    ["x"] = 0.54,
                    ["y"] = -0.125,
                    ["z"] = -0.6000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = -0.30000000000000004,
                    ["z"] = 0.54,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6000000000000001,
                    ["y"] = -0.04999999999999993,
                    ["z"] = 0.48,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.54,
                    ["y"] = 0.30000000000000004,
                    ["z"] = -0.6000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.66,
                    ["y"] = 0.25,
                    ["z"] = 0.54,
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
                ["y"] = -0.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.9,
                ["y"] = 0.9,
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
