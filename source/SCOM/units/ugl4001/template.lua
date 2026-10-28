-- ugl4001: Monkeylord
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Left_Footfall_01",
                    ["contactOffset"] = {
                        ["x"] = 0.003124291166663018,
                        ["y"] = 0.010500147747390276,
                        ["z"] = 0.0027958078973352035,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.5764670604584934,
                        ["y"] = 0.8171203878292942,
                        ["z"] = -2.1899924695922834e-07,
                    },
                    ["length"] = 0.35132837295532227,
                    ["liftHeight"] = 0.2367781514678612,
                    ["minimumHeight"] = -0.1000576968779827,
                    ["plantHeight"] = -0.055057696877982704,
                    ["right"] = {
                        ["x"] = 0.8171203878293125,
                        ["y"] = -0.5764670604585086,
                        ["z"] = -8.080886126915487e-09,
                    },
                    ["width"] = 0.3995707035064697,
                },
                [2] = {
                    ["boneName"] = "Left_Footfall_02",
                    ["contactOffset"] = {
                        ["x"] = -0.0009018059257392963,
                        ["y"] = 0.005017972749428612,
                        ["z"] = 0.007553156472686241,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.9965925420096378,
                        ["y"] = -0.08248215084132876,
                        ["z"] = 1.8320982071440284e-06,
                    },
                    ["length"] = 0.31461287289857864,
                    ["liftHeight"] = 0.20613025943825808,
                    ["minimumHeight"] = -0.043687560632470784,
                    ["plantHeight"] = 0.0013124393675292105,
                    ["right"] = {
                        ["x"] = -0.08248215084029065,
                        ["y"] = -0.9965925420112052,
                        ["z"] = -6.351061914711131e-07,
                    },
                    ["width"] = 0.15693449974060059,
                },
                [3] = {
                    ["boneName"] = "Left_Footfall_03",
                    ["contactOffset"] = {
                        ["x"] = 0.00039034044795686895,
                        ["y"] = 0.025826015617547604,
                        ["z"] = 0.005053131289170737,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.7070052637505667,
                        ["y"] = -0.7072082840499124,
                        ["z"] = -4.1234813918933355e-07,
                    },
                    ["length"] = 0.43938732147216797,
                    ["liftHeight"] = 0.21125331143861903,
                    ["minimumHeight"] = -0.11802060214709328,
                    ["plantHeight"] = -0.07302060214709329,
                    ["right"] = {
                        ["x"] = -0.7072082840495104,
                        ["y"] = -0.707005263749216,
                        ["z"] = -1.6274353619172288e-06,
                    },
                    ["width"] = 0.43938779830932617,
                },
                [4] = {
                    ["boneName"] = "Right_Footfall_01",
                    ["contactOffset"] = {
                        ["x"] = -0.00011301710415055621,
                        ["y"] = 0.012583883952511865,
                        ["z"] = 0.003005993438686745,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.5693446235029723,
                        ["y"] = 0.8220989597902585,
                        ["z"] = 1.8287914615999767e-07,
                    },
                    ["length"] = 0.35132837295532227,
                    ["liftHeight"] = 0.29171644730132834,
                    ["minimumHeight"] = -0.20745461855904881,
                    ["plantHeight"] = -0.1624546185590488,
                    ["right"] = {
                        ["x"] = 0.8220989597902537,
                        ["y"] = 0.5693446235029958,
                        ["z"] = -1.2080079225817997e-07,
                    },
                    ["width"] = 0.39956986904144287,
                },
                [5] = {
                    ["boneName"] = "Right_Footfall_02",
                    ["contactOffset"] = {
                        ["x"] = -0.0017855743989950712,
                        ["y"] = 0.03758598999326779,
                        ["z"] = 0.0075508202855518675,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.996481338764348,
                        ["y"] = -0.0838149240553816,
                        ["z"] = 5.4772967716942844e-08,
                    },
                    ["length"] = 0.31461454555392265,
                    ["liftHeight"] = 0.35835232237565706,
                    ["minimumHeight"] = -0.09587538343429523,
                    ["plantHeight"] = -0.035875383434295235,
                    ["right"] = {
                        ["x"] = -0.08381492405539892,
                        ["y"] = 0.9964813387641982,
                        ["z"] = -5.463584632492413e-07,
                    },
                    ["width"] = 0.20782995223999023,
                },
                [6] = {
                    ["boneName"] = "Right_Footfall_03",
                    ["contactOffset"] = {
                        ["x"] = 0.0006058703189619485,
                        ["y"] = 0.024719045682779495,
                        ["z"] = 0.005059936889493794,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.706115630820435,
                        ["y"] = -0.7080965442019496,
                        ["z"] = 5.622790457682214e-07,
                    },
                    ["length"] = 0.43938755989074707,
                    ["liftHeight"] = 0.28902394892701216,
                    ["minimumHeight"] = -0.07749816549843747,
                    ["plantHeight"] = -0.03249816549843746,
                    ["right"] = {
                        ["x"] = -0.708096544202065,
                        ["y"] = 0.7061156308205434,
                        ["z"] = -8.14640316315618e-09,
                    },
                    ["width"] = 0.4393885135650635,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ugl4001/LOD0/ugl4001_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ugl4001",
        },
        ["scoIdleResetAimPose"] = true,
        ["scoIdleResetLocomotion"] = true,
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2.15,
                ["z"] = 0.66,
            },
            ["size"] = {
                ["x"] = 6.3,
                ["y"] = 7.1,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1345",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1040",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 2.15,
            ["z"] = 0.66,
        },
        ["collisionSize"] = {
            ["x"] = 6,
            ["y"] = 4.4,
            ["z"] = 6.8,
        },
        ["targetBones"] = {
            [1] = "Center_Turret",
            [2] = "Left_Turret",
            [3] = "Right_Turret",
            [4] = "Left_Leg03_B01",
            [5] = "Left_Leg01_B01",
            [6] = "Right_Leg01_B01",
            [7] = "Right_Leg03_B01",
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 45000,
            ["regen"] = 10,
            ["value"] = 45000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 15750,
        ["cost"] = {
            ["alloys"] = 21000,
            ["energy"] = 260000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 250,
        },
    },
    ["footprint"] = {
        ["x"] = 6.4,
        ["y"] = 6.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardMonkeylord",
        },
        ["displayName"] = "Monkeylord",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech3_land1_direct.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Monkeylord",
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
            ["Land"] = 15339.5,
            ["WaterSurface"] = 9166.5,
        },
        ["tpId"] = "ugl4001",
        ["unitTypeName"] = "GuardT4Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 32,
        ["waterVisionRadius"] = 32,
    },
    ["movement"] = {
        ["acceleration"] = 2.5,
        ["collisionMaskDefault"] = {
            [1] = "LandLarge",
            [2] = "SeabedLarge",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandLarge",
            [2] = "SeabedLarge",
        },
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 4.8,
                ["z"] = 0,
            },
        },
        ["mass"] = 0,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 25,
        ["sortOrder"] = 1,
        ["speed"] = 2.5,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsSeabed",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.7142857142857143,
        },
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 64,
        },
        [8] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 64,
        },
        [9] = {
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
    ["skirtSize"] = {
        ["x"] = 8,
        ["y"] = 8,
    },
    ["tags"] = {
        [1] = "ANTI_SURFACE",
        [2] = "BOT",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "DIRECT_FIRE",
        [5] = "GUARD",
        [6] = "LAND",
        [7] = "MOBILE",
        [8] = "SEABED",
        [9] = "TECH4",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_ANTIAIR",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_CYBRAN",
        [15] = "SCFA_DIRECTFIRE",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_EXPERIMENTAL",
        [18] = "SCFA_LAND",
        [19] = "SCFA_MOBILE",
        [20] = "SCFA_NEEDMOBILEBUILD",
        [21] = "SCFA_OVERLAYANTIAIR",
        [22] = "SCFA_OVERLAYANTINAVY",
        [23] = "SCFA_OVERLAYDIRECTFIRE",
        [24] = "SCFA_OVERLAYSONAR",
        [25] = "SCFA_PRODUCTSC1",
        [26] = "SCFA_RECLAIMABLE",
        [27] = "SCFA_SELECTABLE",
        [28] = "SCFA_SONAR",
        [29] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["activate"] = {
                ["clipName"] = "AnimActivate",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl4001/LOD0/ugl4001.sananimation",
            },
            ["construction"] = {
                ["clipName"] = "ConstructionRest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl4001/LOD0/ugl4001.sananimation",
            },
            ["death"] = {
                ["clipName"] = "AnimDeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl4001/LOD0/ugl4001.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.7142857142857143,
                ["clipName"] = "AnimWalk01",
                ["sanAnimationPath"] = "Units/ugl4001/LOD0/ugl4001.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugl4001/LOD0/ugl4001.sananimation",
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
                    ["particleName"] = "VFX/Death/vgd0301_death_rdu.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "Exhaust01",
                ["particleName"] = "VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx",
            },
            [2] = {
                ["boneName"] = "Exhaust02",
                ["particleName"] = "VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx",
            },
            [3] = {
                ["boneName"] = "Exhaust03",
                ["particleName"] = "VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx",
            },
            [4] = {
                ["boneName"] = "Exhaust05",
                ["particleName"] = "VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx",
            },
            [5] = {
                ["boneName"] = "Exhaust06",
                ["particleName"] = "VFX/SupremeCommanderOverhaul/Monkeylord/monkeylord_exhaust_socket.sanvfx",
            },
            [6] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.08,
                    ["y"] = 3.25,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [7] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.32,
                    ["y"] = 2.942,
                    ["z"] = 1.884,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [8] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.2000000000000002,
                    ["y"] = 3.382,
                    ["z"] = 1.7480000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [9] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 1.08,
                    ["y"] = 3.998,
                    ["z"] = -0.7000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [10] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -1.32,
                    ["y"] = 3.91,
                    ["z"] = 1.884,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 186,
            ["lod1distance"] = 485,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2.15,
                ["z"] = 0.66,
            },
            ["size"] = {
                ["x"] = 6.3,
                ["y"] = 7.1,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Center_Turret_Muzzle",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Center_Turret",
                    ["pitchMax"] = 70,
                    ["pitchMin"] = -110,
                    ["pitchSpeed"] = 20,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Center_Turret_B01",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 40,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = true,
                    ["name"] = "aglm5140",
                },
            },
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 1,
                ["fadeOutTime"] = 2,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/Materials/Beam/Beam ugl4001_01.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/Materials/Beam/Beam ugl4001_02.sanmaterial",
                        ["model"] = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = -1,
            ["damage"] = 50,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vgm7401_beam_plasma_huge_muzzle_loop.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Center_Turret_Muzzle",
                        [2] = "Center_Turret_Muzzle_Dual",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Center_Turret_Muzzle"] = {
                    ["aimController"] = "Center_Turret_Muzzle",
                },
                ["Center_Turret_Muzzle_Dual"] = {
                    ["aimController"] = "Center_Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 2,
            ["projectileTemplate"] = "pgd471",
            ["rangeMax"] = 30,
            ["rangeMin"] = 4,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 2,
            ["scomAimAtTargetCollider"] = true,
            ["targetWaterLimits"] = "Above",
            ["waterSensor"] = {
                ["bone"] = "Center_Turret_Muzzle",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        [2] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = -45,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Turret_Barrel",
                    ["pitchMax"] = 35,
                    ["pitchMin"] = -55,
                    ["pitchSpeed"] = 90,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Turret",
                    ["yawMax"] = 45,
                    ["yawMin"] = -135,
                    ["yawSpeed"] = 90,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 150,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vgm1281_cannon_plasma_medium_muzzle.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Turret_Muzzle"] = {
                    ["aimController"] = "Right_Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 2.1028571428571428,
            ["projectileTemplate"] = "psf0087",
            ["rangeMax"] = 64,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 0.6666666666666666,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091",
                ["sourceIndex"] = 2,
                ["sourceLabel"] = "RightLaserTurret",
                ["sourceProjectile"] = "/projectiles/CDFBolter02/CDFBolter02_proj.bp",
            },
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Left_Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 45,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Left_Turret_Barrel",
                    ["pitchMax"] = 80,
                    ["pitchMin"] = -100,
                    ["pitchSpeed"] = 90,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Turret",
                    ["yawMax"] = 135,
                    ["yawMin"] = -45,
                    ["yawSpeed"] = 90,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 150,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/Muzzle/vgm1281_cannon_plasma_medium_muzzle.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Left_Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Left_Turret_Muzzle"] = {
                    ["aimController"] = "Left_Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 2.1028571428571428,
            ["projectileTemplate"] = "psf0087",
            ["rangeMax"] = 64,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 0.6666666666666666,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "f29bbeda9a1d139e330d3cf4d30d7a9cffb80b321e77a2bb86eda7b9471b8091",
                ["sourceIndex"] = 3,
                ["sourceLabel"] = "LeftLaserTurret",
                ["sourceProjectile"] = "/projectiles/CDFBolter02/CDFBolter02_proj.bp",
            },
            ["scoMonkeylordHeadingArc"] = {
                ["center"] = 45,
                ["range"] = 90,
            },
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Projectile01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Projectile01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Projectile01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 40,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile01",
                        [2] = "Right_Projectile02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Projectile01"] = {
                    ["aimController"] = "Right_Projectile01",
                },
                ["Right_Projectile02"] = {
                    ["aimController"] = "Right_Projectile01",
                },
            },
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0006",
            ["rangeMax"] = 64,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "927a795462a0c10f7baa08aef672414b47b04a96236672be24d6a4a03ba0a935",
                ["sourceIndex"] = 4,
                ["sourceLabel"] = "RightAntiAirMissile",
                ["sourceProjectile"] = "/projectiles/CAAMissileNanite02/CAAMissileNanite02_proj.bp",
            },
            ["targetWaterLimits"] = "Above",
        },
        [5] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Left_Projectile01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Left_Projectile01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Left_Projectile01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 40,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Air",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile01",
                        [2] = "Left_Projectile02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Left_Projectile01"] = {
                    ["aimController"] = "Left_Projectile01",
                },
                ["Left_Projectile02"] = {
                    ["aimController"] = "Left_Projectile01",
                },
            },
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "psf0006",
            ["rangeMax"] = 64,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiAir",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 2,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "927a795462a0c10f7baa08aef672414b47b04a96236672be24d6a4a03ba0a935",
                ["sourceIndex"] = 5,
                ["sourceLabel"] = "LeftAntiAirMissile",
                ["sourceProjectile"] = "/projectiles/CAAMissileNanite02/CAAMissileNanite02_proj.bp",
            },
            ["targetWaterLimits"] = "Above",
        },
        [6] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Projectile01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Right_Projectile01",
                    ["pitchMax"] = 0,
                    ["pitchMin"] = 0,
                    ["pitchSpeed"] = 0,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Right_Projectile01",
                    ["yawMax"] = 0,
                    ["yawMin"] = 0,
                    ["yawSpeed"] = 0,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 50,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "WaterSurface",
                [2] = "Water",
                [3] = "Seabed",
            },
            ["layerWeaponLimits"] = {
                [1] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Right_Projectile02",
                    },
                },
                [3] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile01",
                    },
                },
                [4] = {
                    ["muzzles"] = {
                        [1] = "Left_Projectile02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Left_Projectile01"] = {
                    ["aimController"] = "Right_Projectile01",
                },
                ["Left_Projectile02"] = {
                    ["aimController"] = "Right_Projectile01",
                },
                ["Right_Projectile01"] = {
                    ["aimController"] = "Right_Projectile01",
                },
                ["Right_Projectile02"] = {
                    ["aimController"] = "Right_Projectile01",
                },
            },
            ["projectileLifetime"] = 9,
            ["projectileTemplate"] = "psf0084",
            ["rangeMax"] = 45,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiNaval",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 4,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "62fa521286123ca9dc8f8da1a9b7bf60cdcb15ee421b5ca05880c2c48d9045a8",
                ["sourceIndex"] = 6,
                ["sourceLabel"] = "Torpedo",
                ["sourceProjectile"] = "/projectiles/CANTorpedoMeson02/CANTorpedoMeson02_proj.bp",
            },
            ["scoMonkeylordWaterGate"] = "Below",
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "Below",
        },
        [7] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 4000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 7,
            ["damageType"] = "Normal",
        },
    },
}
