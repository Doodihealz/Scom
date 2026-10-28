-- uca2502: Aluminar
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "Units/uca2502/LOD0/uca2502_lod0.sanmodel",
            ["constructionSurfaceModelSha256"] = "53a4e8ca7c16f94c6b0846536992a43b099139268165662eceda555793890fed",
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
                    ["z"] = 6,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAA0104/UAA0104_unit.bp",
            ["sourceBlueprintSha256"] = "a5d905de315ec71969abc312276cbad2495933398cf2318191d712bca3221742",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "AIR",
                [3] = "CANNOTUSEAIRSTAGING",
                [4] = "CANTRANSPORTCOMMANDER",
                [5] = "MOBILE",
                [6] = "OVERLAYANTIAIR",
                [7] = "PRODUCTSC1",
                [8] = "RECLAIMABLE",
                [9] = "SELECTABLE",
                [10] = "TECH2",
                [11] = "TRANSPORTATION",
                [12] = "TRANSPORTBUILTBYTIER2FACTORY",
                [13] = "TRANSPORTBUILTBYTIER3FACTORY",
                [14] = "TRANSPORTFOCUS",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0.4878074526786804,
            ["sourceElevation"] = 9,
            ["sourceId"] = "UAA0104",
            ["sourceKLift"] = 2,
            ["sourceKLiftDamping"] = 2,
            ["sourceLiftFactor"] = 8,
            ["sourceMotionType"] = "RULEUMT_Air",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "uca2502",
            ["weapons"] = {
                [1] = {
                    ["label"] = "SonicPulseBattery1",
                    ["muzzleSalvoSize"] = 3,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_R",
                            },
                            ["rackBone"] = "Turret_Right",
                        },
                    },
                    ["rateOfFire"] = 0.4,
                    ["reloadTime"] = 2.5,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
                },
                [2] = {
                    ["label"] = "SonicPulseBattery2",
                    ["muzzleSalvoSize"] = 3,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_L",
                            },
                            ["rackBone"] = "Turret_Left",
                        },
                    },
                    ["rateOfFire"] = 0.4,
                    ["reloadTime"] = 2.5,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
                },
                [3] = {
                    ["label"] = "SonicPulseBattery3",
                    ["muzzleSalvoSize"] = 3,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_F",
                            },
                            ["rackBone"] = "Turret_Front",
                        },
                    },
                    ["rateOfFire"] = 0.4,
                    ["reloadTime"] = 2.5,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
                },
                [4] = {
                    ["label"] = "SonicPulseBattery4",
                    ["muzzleSalvoSize"] = 3,
                    ["projectilesPerOnFire"] = 1,
                    ["rackFireTogether"] = false,
                    ["rackSalvoSize"] = 1,
                    ["racks"] = {
                        [1] = {
                            ["muzzles"] = {
                                [1] = "Muzzle_B",
                            },
                            ["rackBone"] = "Turret_Back",
                        },
                    },
                    ["rateOfFire"] = 0.4,
                    ["reloadTime"] = 2.5,
                    ["sourceCategory"] = "Anti Air",
                    ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
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
                    ["bone"] = "Attachpoint_Lrg_02",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 15,
                        [2] = 9,
                        [3] = 12,
                        [4] = 7,
                    },
                    ["position"] = {
                        [1] = -2.0128137839492412e-05,
                        [2] = 0.375578404327938,
                        [3] = -1.8435492836060394,
                    },
                },
                [2] = {
                    ["bone"] = "Attachpoint_Lrg_01",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 10,
                        [2] = 4,
                        [3] = 11,
                        [4] = 6,
                    },
                    ["position"] = {
                        [1] = -0.00024862850550562144,
                        [2] = 0.1627113549268018,
                        [3] = -0.6177495205272889,
                    },
                },
                [3] = {
                    ["bone"] = "Attachpoint_Lrg_03",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 21,
                        [2] = 18,
                        [3] = 19,
                        [4] = 16,
                    },
                    ["position"] = {
                        [1] = 0.0012722913175821308,
                        [2] = 0.4991819834996564,
                        [3] = -3.097297965770963,
                    },
                },
                [4] = {
                    ["bone"] = "Right_Attachpoint01",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 4,
                    },
                    ["position"] = {
                        [1] = 0.3204235853302308,
                        [2] = 0.254508684242827,
                        [3] = -0.3016251786368376,
                    },
                },
                [5] = {
                    ["bone"] = "Attachpoint_Med_01",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 6,
                        [2] = 4,
                    },
                    ["position"] = {
                        [1] = 0.21847771956413747,
                        [2] = 0.2976115070823934,
                        [3] = -0.617737653806866,
                    },
                },
                [6] = {
                    ["bone"] = "Right_Attachpoint02",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 6,
                    },
                    ["position"] = {
                        [1] = 0.29124076530469395,
                        [2] = 0.34740909075082876,
                        [3] = -0.9266248603779433,
                    },
                },
                [7] = {
                    ["bone"] = "Right_Attachpoint03",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 7,
                    },
                    ["position"] = {
                        [1] = 0.26205836494191465,
                        [2] = 0.4298240708130012,
                        [3] = -1.5226596362578297,
                    },
                },
                [8] = {
                    ["bone"] = "Attachpoint_Med_02",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 9,
                        [2] = 7,
                    },
                    ["position"] = {
                        [1] = 0.21848037669303194,
                        [2] = 0.4754882597080055,
                        [3] = -1.8435531414010713,
                    },
                },
                [9] = {
                    ["bone"] = "Right_Attachpoint04",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 9,
                    },
                    ["position"] = {
                        [1] = 0.232875898620178,
                        [2] = 0.5106050156898778,
                        [3] = -2.147659028239173,
                    },
                },
                [10] = {
                    ["bone"] = "Left_Attachpoint01",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 10,
                    },
                    ["position"] = {
                        [1] = -0.32046346466638176,
                        [2] = 0.25450907104735837,
                        [3] = -0.30162531853584373,
                    },
                },
                [11] = {
                    ["bone"] = "Left_Attachpoint02",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 11,
                    },
                    ["position"] = {
                        [1] = -0.29068901309229894,
                        [2] = 0.34144450174180296,
                        [3] = -0.926625295538403,
                    },
                },
                [12] = {
                    ["bone"] = "Left_Attachpoint03",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 12,
                    },
                    ["position"] = {
                        [1] = -0.26091453702825634,
                        [2] = 0.4178944132949813,
                        [3] = -1.5226595634526334,
                    },
                },
                [13] = {
                    ["bone"] = "Attachpoint_Med_04",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 11,
                        [2] = 10,
                    },
                    ["position"] = {
                        [1] = -0.21851984752015188,
                        [2] = 0.2976116957896473,
                        [3] = -0.6177382436031453,
                    },
                },
                [14] = {
                    ["bone"] = "Attachpoint_Med_05",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 15,
                        [2] = 12,
                    },
                    ["position"] = {
                        [1] = -0.21852028675807797,
                        [2] = 0.47548799840791134,
                        [3] = -1.8435480943587674,
                    },
                },
                [15] = {
                    ["bone"] = "Left_Attachpoint04",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 15,
                    },
                    ["position"] = {
                        [1] = -0.23114005962410578,
                        [2] = 0.49271028002062955,
                        [3] = -2.1476587450894336,
                    },
                },
                [16] = {
                    ["bone"] = "Left_Attachpoint05",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 16,
                    },
                    ["position"] = {
                        [1] = -0.19252118437819896,
                        [2] = 0.5469678961555273,
                        [3] = -2.772659662672655,
                    },
                },
                [17] = {
                    ["bone"] = "Attachpoint_Med_06",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 18,
                        [2] = 16,
                    },
                    ["position"] = {
                        [1] = -0.21851989516040496,
                        [2] = 0.5790841609256541,
                        [3] = -3.0973225531296986,
                    },
                },
                [18] = {
                    ["bone"] = "Left_Attachpoint06",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 18,
                    },
                    ["position"] = {
                        [1] = -0.164849718090184,
                        [2] = 0.6148874879815929,
                        [3] = -3.3976596141407907,
                    },
                },
                [19] = {
                    ["bone"] = "Right_Attachpoint05",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 19,
                    },
                    ["position"] = {
                        [1] = 0.1930241293327909,
                        [2] = 0.5483126753607005,
                        [3] = -2.77266002850013,
                    },
                },
                [20] = {
                    ["bone"] = "Attachpoint_Med_03",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 21,
                        [2] = 19,
                    },
                    ["position"] = {
                        [1] = 0.2184796412375711,
                        [2] = 0.5790848909675614,
                        [3] = -3.097322692580004,
                    },
                },
                [21] = {
                    ["bone"] = "Right_Attachpoint06",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 21,
                    },
                    ["position"] = {
                        [1] = 0.1653523464718788,
                        [2] = 0.6162317812735396,
                        [3] = -3.397659704002682,
                    },
                },
            },
            ["sourceId"] = "UAA0104",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 131140,
                ["entry"] = "units/UAA0104/UAA0104_LOD0.scm",
                ["sha256"] = "79b78686cc1a387f7e8754e50810334b47a1b88141da658d10e3cc36ef330045",
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
                ["y"] = -0.25,
                ["z"] = -1.5,
            },
            ["size"] = {
                ["x"] = 2.75,
                ["y"] = 3.8,
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
            ["y"] = -0.25,
            ["z"] = -1.5,
        },
        ["collisionSize"] = {
            ["x"] = 2.2,
            ["y"] = 2.5,
            ["z"] = 6,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2500,
            ["regen"] = 0,
            ["value"] = 2500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1200,
        ["cost"] = {
            ["alloys"] = 150,
            ["energy"] = 4800,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortAirUnit",
        },
        ["displayName"] = "Aluminar",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_air1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Aluminar",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["Transport"] = true,
        },
        ["tpId"] = "uca2502",
        ["unitTypeName"] = "Aluminar",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 15,
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
        ["orbitRange"] = 9.549296585513721,
        ["orbitSpeed"] = 15,
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
        ["preferredAltitude"] = 9,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 4,
        ["speed"] = 15,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Gunship",
    },
    ["ranges"] = {
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
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
        [1] = "AIR",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CHOSEN",
        [5] = "GUNSHIP",
        [6] = "MOBILE",
        [7] = "TECH2",
        [8] = "TRANSPORT",
        [9] = "SCFA_AEON",
        [10] = "SCFA_AIR",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_CANNOTUSEAIRSTAGING",
        [13] = "SCFA_CANTRANSPORTCOMMANDER",
        [14] = "SCFA_MOBILE",
        [15] = "SCFA_OVERLAYANTIAIR",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_TECH2",
        [20] = "SCFA_TRANSPORTATION",
        [21] = "SCFA_TRANSPORTBUILTBYTIER2FACTORY",
        [22] = "SCFA_TRANSPORTBUILTBYTIER3FACTORY",
        [23] = "SCFA_TRANSPORTFOCUS",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animaopen01"] = {
                ["clipName"] = "AnimAopen01",
                ["sanAnimationPath"] = "Units/uca2502/LOD0/uca2502.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/uca2502/LOD0/uca2502.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.396,
                    ["y"] = 0.375,
                    ["z"] = -2.7,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.48400000000000004,
                    ["y"] = 0.19999999999999996,
                    ["z"] = -0.41999999999999993,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.44000000000000006,
                    ["y"] = 0.45000000000000007,
                    ["z"] = -0.54,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.396,
                    ["y"] = 0.8,
                    ["z"] = -2.7,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.48400000000000004,
                    ["y"] = 0.75,
                    ["z"] = -0.41999999999999993,
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
                ["y"] = -0.25,
                ["z"] = -1.5,
            },
            ["size"] = {
                ["x"] = 2.75,
                ["y"] = 3.8,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle_R",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Right",
                    ["pitchMax"] = 75,
                    ["pitchMin"] = -75,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Right",
                    ["yawMax"] = 90,
                    ["yawMin"] = -90,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 6,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca2502/muzzle_sonicpulsebattery1.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_R",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Muzzle_R"] = {
                    ["aimController"] = "Muzzle_R",
                },
            },
            ["projectileLifetime"] = 0.7142857142857142,
            ["projectileTemplate"] = "psf0048",
            ["rangeMax"] = 20,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "04fda000ad8a4be8036c2d76809c568abad59d7badb275f433e11c546be138a8",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "SonicPulseBattery1",
                ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "SonicPulseBattery1",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "SonicPulseBattery1",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle_L",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Left",
                    ["pitchMax"] = 75,
                    ["pitchMin"] = -75,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Left",
                    ["yawMax"] = 90,
                    ["yawMin"] = -90,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 6,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca2502/muzzle_sonicpulsebattery2.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_L",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Muzzle_L"] = {
                    ["aimController"] = "Muzzle_L",
                },
            },
            ["projectileLifetime"] = 0.7142857142857142,
            ["projectileTemplate"] = "psf0048",
            ["rangeMax"] = 20,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "04fda000ad8a4be8036c2d76809c568abad59d7badb275f433e11c546be138a8",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "SonicPulseBattery2",
                ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "SonicPulseBattery2",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "SonicPulseBattery2",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle_F",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Front",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Front",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 6,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca2502/muzzle_sonicpulsebattery3.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_F",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Muzzle_F"] = {
                    ["aimController"] = "Muzzle_F",
                },
            },
            ["projectileLifetime"] = 0.7142857142857142,
            ["projectileTemplate"] = "psf0048",
            ["rangeMax"] = 20,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "04fda000ad8a4be8036c2d76809c568abad59d7badb275f433e11c546be138a8",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "SonicPulseBattery3",
                ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "SonicPulseBattery3",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "SonicPulseBattery3",
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Muzzle_B",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.5,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Back",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 360,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_Back",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 360,
                },
            },
            ["damage"] = 6,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/uca2502/muzzle_sonicpulsebattery4.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = 10,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Muzzle_B",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 3,
            ["muzzles"] = {
                ["Muzzle_B"] = {
                    ["aimController"] = "Muzzle_B",
                },
            },
            ["projectileLifetime"] = 0.7142857142857142,
            ["projectileTemplate"] = "psf0048",
            ["rangeMax"] = 20,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "04fda000ad8a4be8036c2d76809c568abad59d7badb275f433e11c546be138a8",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "SonicPulseBattery4",
                ["sourceProjectile"] = "/projectiles/AAASonicPulse02/AAASonicPulse02_proj.bp",
            },
            ["scoSourceCategory"] = "Anti Air",
            ["scoSourceLabel"] = "SonicPulseBattery4",
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "SonicPulseBattery4",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
