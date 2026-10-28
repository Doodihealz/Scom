-- ugl0000: Armored Command Unit
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["version"] = "1.0.0",
            ["projectileTemplate"] = "poccybran",
        },
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle_01",
        },
        ["buildBeamEffectName"] = "beam1",
        ["displayWreckOnDeath"] = false,
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -4.1579633341248624e-07,
                [2] = 2.1381723185302532,
                [3] = -0.23610023867679705,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = true,
            ["foldDuration"] = 2.6666667461395264,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0001",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 629288,
                ["entry"] = "units/URL0001/URL0001_lod0.scm",
                ["sha256"] = "24abeaf2031c031375ea8bec8b055add6175f76df72712b3c4ecf7001cb3188f",
            },
            ["unfoldDuration"] = 0.5333333611488342,
        },
        ["scoCommanderEnhancementBaseWeaponIndex"] = 1,
        ["scoCommanderEnhancementWeapons"] = {
            ["MLG"] = 3,
            ["Torpedo"] = 4,
        },
        ["scoCommanderEnhancements"] = {
            ["baseBuildCategory"] = "Tags.GUARD * Tags.BUILDABLE_BY_T1_ENGINEER",
            ["capabilities"] = {
                ["chronoStun"] = false,
                ["cloak"] = "visual-aura",
                ["manualMissiles"] = false,
                ["omni"] = false,
                ["sonar"] = false,
                ["spawnPods"] = false,
                ["stealth"] = "visual-aura",
                ["teleport"] = true,
            },
            ["faction"] = "Cybran",
            ["patchVersion"] = "1.0.4",
            ["radarPredeclared"] = false,
            ["sourceId"] = "URL0001",
            ["version"] = "1.0.0",
        },
        ["scoGameplayCommanderBeam"] = "1.3.0",
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Left_Footprint",
                    ["contactOffset"] = {
                        ["x"] = 0.004924373626709,
                        ["y"] = -0.021331611256782075,
                        ["z"] = 0.04111559211606623,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 0,
                        ["y"] = 1.1920930376163512e-07,
                        ["z"] = 0.9999999999999929,
                    },
                    ["length"] = 0.5905695557594299,
                    ["liftHeight"] = 0.0459848394443331,
                    ["minimumHeight"] = -0.05950781701760756,
                    ["plantHeight"] = -0.014507817017607557,
                    ["right"] = {
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["width"] = 0.3539043664932251,
                },
                [2] = {
                    ["boneName"] = "Right_Footprint",
                    ["contactOffset"] = {
                        ["x"] = -0.007341677859369733,
                        ["y"] = -0.021279815255236232,
                        ["z"] = 0.04114417015754598,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = -2.486694327177779e-10,
                        ["y"] = 0.0028363437502871088,
                        ["z"] = 0.9999959775689752,
                    },
                    ["length"] = 0.5905695855617523,
                    ["liftHeight"] = 0.04818454639893624,
                    ["minimumHeight"] = -0.060729354101049945,
                    ["plantHeight"] = -0.01572935410104995,
                    ["right"] = {
                        ["x"] = 0.9999999999999961,
                        ["y"] = 8.767039459343143e-08,
                        ["z"] = 6.0569518566669976e-15,
                    },
                    ["width"] = 0.3539043590426445,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ugl0000/LOD0/ugl0000_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ugl0000",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scomRestoredAnimations"] = {
            ["assetSha256"] = "78b04c7ce842f9934fe4c240e0aaf8c9139ac5428b35b693a3225ec794a5f473",
            ["runtimeRate"] = 1,
            ["sourceDeathRateRandomization"] = false,
            ["sourceId"] = "URL0001",
            ["transportEventBinding"] = "source cargo load/unload lifecycle",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.2,
                ["z"] = 0.19,
            },
            ["size"] = {
                ["x"] = 1.8,
                ["y"] = 1.9,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1305",
        },
        ["onDamagedAlert"] = {
            ["looping"] = false,
            ["name"] = "dx_uni_evaf_Pxx_Sc",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod0000",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.2,
            ["z"] = 0.19,
        },
        ["collisionSize"] = {
            ["x"] = 1.6,
            ["y"] = 2.6,
            ["z"] = 1.7,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Turret_Muzzle_01",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.GUARD * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 10,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10000,
            ["regen"] = 15,
            ["value"] = 10000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80000,
        ["cost"] = {
            ["alloys"] = 10000,
            ["energy"] = 100000,
        },
        ["initial"] = {
            ["alloys"] = 650,
            ["energy"] = 4000,
        },
        ["production"] = {
            ["alloys"] = 1,
            ["energy"] = 20,
        },
        ["storage"] = {
            ["alloys"] = 650,
            ["energy"] = 5000,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2.1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardCommander",
        },
        ["displayName"] = "Armored Command Unit",
        ["icon"] = {
            ["shape"] = "bot2",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_bot2_direct.png",
        ["iconUIBuildSortPriority"] = 1000,
        ["iconUIType"] = "land",
        ["name"] = "Armored Command Unit",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Pause"] = false,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 251.8,
            ["WaterSurface"] = 251.8,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ugl0000",
        ["unitTypeName"] = "GuardCommander",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 1.7,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "SeabedSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "SeabedSmall",
        },
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.9,
                ["z"] = 0,
            },
        },
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 1.7,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsSeabed",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 1,
        },
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 10,
        },
        [6] = {
            ["innerRadius"] = 1,
            ["outerRadius"] = 22,
        },
        [9] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 60,
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
        [1] = "ALLOYS_PRODUCTION",
        [2] = "ALLOYS_STORAGE",
        [3] = "ANTI_SURFACE",
        [4] = "CAPTURE",
        [5] = "COMMAND",
        [6] = "CONSTRUCTION",
        [7] = "DIRECT_FIRE",
        [8] = "ECONOMIC",
        [9] = "ENERGY_PRODUCTION",
        [10] = "ENERGY_STORAGE",
        [11] = "GUARD",
        [12] = "HARVEST",
        [13] = "LAND",
        [14] = "MOBILE",
        [15] = "SEABED",
        [16] = "TECH1",
        [17] = "SCFA_ALLUNITS",
        [18] = "SCFA_CAPTURE",
        [19] = "SCFA_COMMAND",
        [20] = "SCFA_CONSTRUCTION",
        [21] = "SCFA_CYBRAN",
        [22] = "SCFA_DIRECTFIRE",
        [23] = "SCFA_ECONOMIC",
        [24] = "SCFA_ENERGYPRODUCTION",
        [25] = "SCFA_ENGINEER",
        [26] = "SCFA_LAND",
        [27] = "SCFA_MASSFABRICATION",
        [28] = "SCFA_MASSPRODUCTION",
        [29] = "SCFA_MOBILE",
        [30] = "SCFA_OVERLAYDIRECTFIRE",
        [31] = "SCFA_OVERLAYOMNI",
        [32] = "SCFA_PATROLHELPER",
        [33] = "SCFA_PRODUCTSC1",
        [34] = "SCFA_RECLAIM",
        [35] = "SCFA_REPAIR",
        [36] = "SCFA_SELECTABLE",
        [37] = "SCFA_SHOWQUEUE",
        [38] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl0000/LOD0/ugl0000.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl0000/LOD0/ugl0000.sananimation",
            },
            ["fold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl0000/LOD0/ugl0000.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimWalk01",
                ["sanAnimationPath"] = "Units/ugl0000/LOD0/ugl0000.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["unfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl0000/LOD0/ugl0000.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugl0000/LOD0/ugl0000.sananimation",
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
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.288,
                    ["y"] = 1.85,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 1.668,
                    ["z"] = 0.496,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.32000000000000006,
                    ["y"] = 1.928,
                    ["z"] = 0.462,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.288,
                    ["y"] = 2.292,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.35200000000000004,
                    ["y"] = 2.24,
                    ["z"] = 0.496,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 75,
            ["lod1distance"] = 197,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.2,
                ["z"] = 0.19,
            },
            ["size"] = {
                ["x"] = 1.8,
                ["y"] = 1.9,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_02",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Turret",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 90,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom3100",
                },
            },
            ["damage"] = 100,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/CommanderBrightness/79ba050abdfc07e0a53d.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_02",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle_02"] = {
                    ["aimController"] = "Turret_Muzzle_02",
                },
            },
            ["projectileLifetime"] = 3,
            ["projectileTemplate"] = "psf0166",
            ["rangeMax"] = 22,
            ["rangeMin"] = 1,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoCommanderEnhancementBaseWeapon"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "fd24fa44f96c18b55b2da3f767a7dc85c6bb6556c7e508040d81cd831b754d1e",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "RightRipper",
                ["sourceProjectile"] = "/projectiles/CDFCannonMolecular01/CDFCannonMolecular01_proj.bp",
            },
            ["targetWaterLimits"] = "Above",
            ["waterSensor"] = {
                ["bone"] = "Turret_Muzzle_02",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 5000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 15,
            ["damageType"] = "Normal",
        },
        [3] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_03",
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Muzzle_03",
                    ["pitchMax"] = 80,
                    ["pitchMin"] = -80,
                    ["pitchSpeed"] = 20,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 30,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Center_Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 30,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = true,
                    ["name"] = "aglm5130",
                },
            },
            ["beam"] = {
                ["cullDistance"] = 500,
                ["fadeInTime"] = 0,
                ["fadeOutTime"] = 0.1,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/SCOM/Source/CommanderBrightness/bf77ab57130f809e25e7.sanmaterial",
                        ["model"] = "VFX/SupremeCommanderOverhaul/Models/Monkeylord/monkeylord_microwave_beam.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = -1,
            ["damage"] = 800,
            ["damageRadius"] = 0.5,
            ["damageType"] = "Normal",
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "pxd003",
            ["rangeMax"] = 22,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 0.3333333333333333,
            ["scoCommanderEnhancementRequired"] = "MicrowaveLaserGenerator",
            ["scoCommanderEnhancementWeaponId"] = "MLG",
            ["scoCommanderMicrowave"] = {
                ["collisionTicks"] = 2,
                ["damageRadius"] = 0.5,
            },
            ["targetWaterLimits"] = "Above",
        },
        [4] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "AttachPoint",
                    ["aimTolerance"] = 180,
                    ["leadTarget"] = false,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 5,
                    ["solverType"] = "NoArc",
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom1110",
                },
            },
            ["damage"] = 250,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/CommanderBrightness/cf89c7d9bbd679dcec96.sanvfx",
            },
            ["firingRandomness"] = 1,
            ["layerTargetLimits"] = {
                [1] = "Water",
                [2] = "WaterSurface",
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
                        [1] = "SCOTorpedoMuzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.8,
            ["muzzleSalvoSize"] = 4,
            ["muzzles"] = {
                ["SCOTorpedoMuzzle"] = {
                    ["aimController"] = "AttachPoint",
                },
            },
            ["projectileLifetime"] = 7,
            ["projectileTemplate"] = "pgr305t",
            ["rangeMax"] = 60,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "AntiNaval",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 4,
            ["scoCommanderEnhancementRequired"] = "NaniteTorpedoTube",
            ["scoCommanderEnhancementWeaponId"] = "Torpedo",
            ["scoCommanderSourceMuzzleBone"] = "Turret_Muzzle_03",
            ["scoCommanderTargetFilter"] = "NavalMobileNonHover",
            ["scoTorpedoWeapon"] = true,
            ["targetWaterLimits"] = "None",
        },
    },
}
