-- usa2502: Vishala
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
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
                    ["bone"] = "Right_Attachpoint01",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 1,
                    },
                    ["position"] = {
                        [1] = -1.5226832353060011,
                        [2] = 0.044494313349029035,
                        [3] = 0.594326762729859,
                    },
                },
                [2] = {
                    ["bone"] = "Right_Attachpoint02",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 2,
                    },
                    ["position"] = {
                        [1] = -1.5627608642327349,
                        [2] = 0.029890868379889097,
                        [3] = 1.2002621249912206,
                    },
                },
                [3] = {
                    ["bone"] = "Right_Attachpoint03",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 3,
                    },
                    ["position"] = {
                        [1] = -1.5308763079410679,
                        [2] = 0.03946086365962655,
                        [3] = 1.8163798436470764,
                    },
                },
                [4] = {
                    ["bone"] = "Right_Attachpoint04",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 4,
                    },
                    ["position"] = {
                        [1] = -1.4591073294755745,
                        [2] = 0.06218250618776523,
                        [3] = 2.460171412405929,
                    },
                },
                [5] = {
                    ["bone"] = "Right_Attachpoint05",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 5,
                    },
                    ["position"] = {
                        [1] = -1.3180926580324077,
                        [2] = 0.07823168013426732,
                        [3] = 3.0375459237777207,
                    },
                },
                [6] = {
                    ["bone"] = "Right_Attachpoint07",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 6,
                    },
                    ["position"] = {
                        [1] = -0.9810028697054597,
                        [2] = 0.1240137403032941,
                        [3] = 4.218680639009017,
                    },
                },
                [7] = {
                    ["bone"] = "Right_Attachpoint08",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 7,
                    },
                    ["position"] = {
                        [1] = -0.7356855416195288,
                        [2] = 0.1659066927470773,
                        [3] = 4.704290972284428,
                    },
                },
                [8] = {
                    ["bone"] = "Left_Attachpoint02",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 8,
                    },
                    ["position"] = {
                        [1] = 1.5258105750558686,
                        [2] = 0.02989086414171936,
                        [3] = 1.219907019202877,
                    },
                },
                [9] = {
                    ["bone"] = "Left_Attachpoint03",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 9,
                    },
                    ["position"] = {
                        [1] = 1.5306054809621648,
                        [2] = 0.03946086476735214,
                        [3] = 1.834890863311873,
                    },
                },
                [10] = {
                    ["bone"] = "Left_Attachpoint04",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 10,
                    },
                    ["position"] = {
                        [1] = 1.4605370414785117,
                        [2] = 0.06218250756339351,
                        [3] = 2.4591238198655905,
                    },
                },
                [11] = {
                    ["bone"] = "Left_Attachpoint05",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 11,
                    },
                    ["position"] = {
                        [1] = 1.3079221228788578,
                        [2] = 0.07823167774837889,
                        [3] = 3.06708823301375,
                    },
                },
                [12] = {
                    ["bone"] = "Left_Attachpoint06",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 12,
                    },
                    ["position"] = {
                        [1] = 1.1213614889582713,
                        [2] = 0.09948790722685444,
                        [3] = 3.653290820569911,
                    },
                },
                [13] = {
                    ["bone"] = "Left_Attachpoint07",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 13,
                    },
                    ["position"] = {
                        [1] = 0.9844791060239546,
                        [2] = 0.14666645505933876,
                        [3] = 4.1963530318080915,
                    },
                },
                [14] = {
                    ["bone"] = "Left_Attachpoint08",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 14,
                    },
                    ["position"] = {
                        [1] = 0.780869958144225,
                        [2] = 0.16590670723955345,
                        [3] = 4.763433569536882,
                    },
                },
                [15] = {
                    ["bone"] = "Left_Attachpoint01",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 15,
                    },
                    ["position"] = {
                        [1] = 1.5153571895352136,
                        [2] = 0.04449431519052555,
                        [3] = 0.6155530967024809,
                    },
                },
                [16] = {
                    ["bone"] = "Attachpoint_Med01",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 1,
                        [2] = 2,
                    },
                    ["position"] = {
                        [1] = -1.4282988390805318,
                        [2] = 0.013817746448670074,
                        [3] = 0.8819686164672945,
                    },
                },
                [17] = {
                    ["bone"] = "Attachpoint_Med02",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 3,
                        [2] = 4,
                    },
                    ["position"] = {
                        [1] = -1.4032742067662058,
                        [2] = 0.036930731581086805,
                        [3] = 2.11410869753371,
                    },
                },
                [18] = {
                    ["bone"] = "Attachpoint_Med03",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 23,
                        [2] = 5,
                    },
                    ["position"] = {
                        [1] = -1.1685125818384239,
                        [2] = 0.08765737113912403,
                        [3] = 3.3248793646801675,
                    },
                },
                [19] = {
                    ["bone"] = "Attachpoint_Med04",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 6,
                        [2] = 7,
                    },
                    ["position"] = {
                        [1] = -0.8024534617707213,
                        [2] = 0.15150950531537108,
                        [3] = 4.430443882264319,
                    },
                },
                [20] = {
                    ["bone"] = "Attachpoint_Lrg01",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 23,
                        [2] = 6,
                        [3] = 5,
                        [4] = 7,
                    },
                    ["position"] = {
                        [1] = -0.9418083705521685,
                        [2] = 0.12013973501395679,
                        [3] = 3.8199790802486535,
                    },
                },
                [21] = {
                    ["bone"] = "Attachpoint_Lrg02",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 8,
                        [2] = 15,
                        [3] = 9,
                        [4] = 10,
                    },
                    ["position"] = {
                        [1] = 1.101536767022491,
                        [2] = 0.06620011902720369,
                        [3] = 0.9515178468473193,
                    },
                },
                [22] = {
                    ["bone"] = "Attachpoint_Lrg03",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 2,
                        [2] = 1,
                        [3] = 3,
                        [4] = 4,
                    },
                    ["position"] = {
                        [1] = -1.1015449361704646,
                        [2] = 0.06620011445046668,
                        [3] = 0.9515106018614573,
                    },
                },
                [23] = {
                    ["bone"] = "Right_Attachpoint06",
                    ["cargoClass"] = 1,
                    ["occupies"] = {
                        [1] = 23,
                    },
                    ["position"] = {
                        [1] = -1.160099341296904,
                        [2] = 0.0994879080394161,
                        [3] = 3.6265377906867586,
                    },
                },
                [24] = {
                    ["bone"] = "Attachpoint_Med05",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 15,
                        [2] = 8,
                    },
                    ["position"] = {
                        [1] = 1.4237185478210452,
                        [2] = 0.007450351210012401,
                        [3] = 0.8804867753327313,
                    },
                },
                [25] = {
                    ["bone"] = "Attachpoint_Med06",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 9,
                        [2] = 10,
                    },
                    ["position"] = {
                        [1] = 1.4095687243239985,
                        [2] = 0.03276856325939103,
                        [3] = 2.113041644289543,
                    },
                },
                [26] = {
                    ["bone"] = "Attachpoint_Med07",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 11,
                        [2] = 12,
                    },
                    ["position"] = {
                        [1] = 1.214283380743442,
                        [2] = 0.0906772391115236,
                        [3] = 3.318823480535793,
                    },
                },
                [27] = {
                    ["bone"] = "Attachpoint_Med08",
                    ["cargoClass"] = 2,
                    ["occupies"] = {
                        [1] = 13,
                        [2] = 14,
                    },
                    ["position"] = {
                        [1] = 0.8213575742813986,
                        [2] = 0.12717918789899924,
                        [3] = 4.430895295479207,
                    },
                },
                [28] = {
                    ["bone"] = "Attachpoint_Lrg04",
                    ["cargoClass"] = 3,
                    ["occupies"] = {
                        [1] = 12,
                        [2] = 13,
                        [3] = 11,
                        [4] = 14,
                    },
                    ["position"] = {
                        [1] = 0.863962907024977,
                        [2] = 0.12019349546186892,
                        [3] = 3.819690050745134,
                    },
                },
            },
            ["sourceId"] = "XSA0104",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 167559,
                ["entry"] = "units/XSA0104/XSA0104_lod0.scm",
                ["sha256"] = "8985f0b7b3253d63bc3e74bf2c7b11e32f2c3a22961284d3e48b9cca2f9252dc",
            },
            ["sourceTransport"] = {
                ["AirClass"] = true,
                ["Class2AttachSize"] = 2,
                ["Class3AttachSize"] = 4,
                ["TransportClass"] = 10,
            },
        },
        ["scoMissingCrashImpact"] = {
            ["damage"] = 25,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["sourceBlueprintSha256"] = "96b25721f6701cb9df1f64b790b68f8f80b570d2d53bc9eb1876af6ece79f0bd",
            ["sourceId"] = "XSA0104",
            ["sourceIndex"] = 4,
            ["targetId"] = "usa2502",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = -0.1,
                ["z"] = 1.5,
            },
            ["size"] = {
                ["x"] = 2.1,
                ["y"] = 4.5,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod5120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = -0.1,
            ["z"] = 1.5,
        },
        ["collisionSize"] = {
            ["x"] = 4.5,
            ["y"] = 2.8,
            ["z"] = 7,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 4000,
            ["regen"] = 0,
            ["value"] = 4000,
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
        ["x"] = 3,
        ["y"] = 5,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimAirUnit",
        },
        ["displayName"] = "Vishala",
        ["icon"] = {
            ["shape"] = "air1",
            ["symbol"] = "none",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_air1_none.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "air",
        ["name"] = "Vishala",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
            ["Transport"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "usa2502",
        ["unitTypeName"] = "UnknownT2Transport",
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
        ["orbitRange"] = 9.54929658551372,
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
        ["sortOrder"] = 5,
        ["speed"] = 15,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Gunship",
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 22,
        },
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
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "MOBILE",
        [4] = "SCFA_AIR",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_CANNOTUSEAIRSTAGING",
        [7] = "SCFA_CANTRANSPORTCOMMANDER",
        [8] = "SCFA_MOBILE",
        [9] = "SCFA_OVERLAYANTIAIR",
        [10] = "SCFA_OVERLAYDIRECTFIRE",
        [11] = "SCFA_PRODUCTFA",
        [12] = "SCFA_RECLAIMABLE",
        [13] = "SCFA_SELECTABLE",
        [14] = "SCFA_SERAPHIM",
        [15] = "SCFA_TECH2",
        [16] = "SCFA_TRANSPORTATION",
        [17] = "SCFA_TRANSPORTBUILTBYTIER2FACTORY",
        [18] = "SCFA_TRANSPORTBUILTBYTIER3FACTORY",
        [19] = "SCFA_TRANSPORTFOCUS",
        [20] = "SCFA_VISIBLETORECON",
        [21] = "SERAPHIM",
        [22] = "TECH2",
        [23] = "TRANSPORT",
        [24] = "AIR",
        [25] = "GUNSHIP",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/usa2502/LOD0/usa2502.sananimation",
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
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd3201_death_air_medium.sanvfx",
                },
            },
            ["onImpact"] = {
                [1] = {
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd3201_death_air_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8099999999999999,
                    ["y"] = 0.6,
                    ["z"] = 0.09999999999999987,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.99,
                    ["y"] = 0.404,
                    ["z"] = 2.76,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.9,
                    ["y"] = 0.684,
                    ["z"] = 2.62,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8099999999999999,
                    ["y"] = 1.0759999999999998,
                    ["z"] = 0.09999999999999987,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.99,
                    ["y"] = 1.0199999999999998,
                    ["z"] = 2.76,
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
                ["y"] = -0.1,
                ["z"] = 1.5,
            },
            ["size"] = {
                ["x"] = 2.1,
                ["y"] = 4.5,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Left_Turret_Barrel_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Left_Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 60,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 5,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa2502/muzzle_aaleft.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Left_Turret_Barrel_Muzzle01",
                        [2] = "Left_Turret_Barrel_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Left_Turret_Barrel_Muzzle01"] = {
                    ["aimController"] = "Left_Turret_Barrel_Muzzle01",
                },
                ["Left_Turret_Barrel_Muzzle02"] = {
                    ["aimController"] = "Left_Turret_Barrel_Muzzle01",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0112",
            ["rangeMax"] = 20,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "9539620fea362f051a424ba168d0bb2efc9887e1a522037fd2a7f579f0a7c3c6",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AALeft",
                ["sourceProjectile"] = "/projectiles/SAAShleoAAGatlingGun04/SAAShleoAAGatlingGun04_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "AALeft",
            },
            ["targetWaterLimits"] = "Above",
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Turret_Barrel_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 60,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 5,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa2502/muzzle_aaright.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Turret_Barrel_Muzzle01",
                        [2] = "Right_Turret_Barrel_Muzzle02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 2,
            ["muzzles"] = {
                ["Right_Turret_Barrel_Muzzle01"] = {
                    ["aimController"] = "Right_Turret_Barrel_Muzzle01",
                },
                ["Right_Turret_Barrel_Muzzle02"] = {
                    ["aimController"] = "Right_Turret_Barrel_Muzzle01",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0112",
            ["rangeMax"] = 20,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.5,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "9539620fea362f051a424ba168d0bb2efc9887e1a522037fd2a7f579f0a7c3c6",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AARight",
                ["sourceProjectile"] = "/projectiles/SAAShleoAAGatlingGun04/SAAShleoAAGatlingGun04_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "AARight",
            },
            ["targetWaterLimits"] = "Above",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Center_Turret_Barrel_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Center_Turret_Barrel_Muzzle",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -25,
                    ["pitchSpeed"] = 60,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 13,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Center_Turret_Barrel_Muzzle",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["damage"] = 2,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/usa2502/muzzle_autogun.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Air",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Center_Turret_Barrel_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.1,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Center_Turret_Barrel_Muzzle"] = {
                    ["aimController"] = "Center_Turret_Barrel_Muzzle",
                },
            },
            ["projectileLifetime"] = 8,
            ["projectileTemplate"] = "psf0126",
            ["rangeMax"] = 22,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "7cb47725b1e530a97af904ed55ae998b6249f0a15d2e52d14949c3d1f7c032e4",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "AutoGun",
                ["sourceProjectile"] = "/projectiles/SDFHeavyPhasicAutogun01/SDFHeavyPhasicAutogun01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "AutoGun",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
