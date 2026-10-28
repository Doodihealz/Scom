-- ues5042: Ravager
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["fuelIntentionallyOmitted"] = false,
            ["runtimeBehaviorApproval"] = false,
            ["sourceAir"] = {},
            ["sourceAnimations"] = {
                [1] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {
                        [1] = "Turret_Barrel",
                        [2] = "Exhaust",
                        [3] = "Muzzle",
                    },
                    ["blueprintUses"] = {},
                    ["bytes"] = 2529,
                    ["clipName"] = "FaXEB2306afire",
                    ["duration"] = 0.5,
                    ["entry"] = "units/XEB2306/XEB2306_afire.sca",
                    ["frames"] = 16,
                    ["outputDuration"] = 0.5,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "48373585ff20d629102b279f9d944e910eefb2548c00daf2b580f0aa9c28fc95",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 5,
                    ["usedBySource"] = false,
                },
            },
            ["sourceBlueprint"] = "units/XEB2306/XEB2306_unit.bp",
            ["sourceBlueprintSha256"] = "44010918c0950cf314a8fb013742976f0fe164f32ceeb4d0c7116d3c0b0869de",
            ["sourceBuildableCategory"] = {},
            ["sourceId"] = "XEB2306",
            ["sourceIntel"] = {
                ["VisionRadius"] = 24,
            },
            ["sourceMovement"] = {
                ["BankingSlope"] = 0,
                ["BuildOnLayerCaps"] = {
                    ["LAYER_Air"] = false,
                    ["LAYER_Land"] = true,
                    ["LAYER_Orbit"] = false,
                    ["LAYER_Seabed"] = false,
                    ["LAYER_Sub"] = false,
                    ["LAYER_Water"] = false,
                },
                ["DragCoefficient"] = 0.2,
                ["FlattenSkirt"] = true,
                ["MaxSteerForce"] = 0,
                ["MeshExtentsX"] = 1.1,
                ["MeshExtentsY"] = 1.15,
                ["MeshExtentsZ"] = 1.1,
                ["MinSpeedPercent"] = 0,
                ["MotionType"] = "RULEUMT_None",
                ["SkirtOffsetX"] = -0.5,
                ["SkirtOffsetZ"] = -0.5,
                ["SkirtSizeX"] = 2,
                ["SkirtSizeZ"] = 2,
                ["TurnRate"] = 0,
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2251,
                ["entry"] = "units/XEB2306/XEB2306_Script.lua",
                ["sha256"] = "479939bdb84ccc7e13fdd0e776c5cb54e6c79397a26285c6c56be930adf408e5",
            },
            ["sourceShield"] = {},
            ["sourceWeapons"] = {
                [1] = {
                    ["AboveWaterTargetsOnly"] = true,
                    ["AimsStraightOnDisable"] = true,
                    ["Audio"] = {
                        ["Fire"] = {
                            ["Bank"] = "XEL_Weapons",
                            ["Cue"] = "XEB2306_Gatling_Gun",
                            ["LodCutoff"] = "Weapon_LodCutoff",
                        },
                    },
                    ["BallisticArc"] = "RULEUBA_None",
                    ["CollideFriendly"] = false,
                    ["Damage"] = 175,
                    ["DamageRadius"] = 1,
                    ["DamageType"] = "Normal",
                    ["DisplayName"] = "Heavy Plasma Gatling Cannon",
                    ["EnergyDrainPerSecond"] = 50,
                    ["EnergyRequired"] = 50,
                    ["FireTargetLayerCapsTable"] = {
                        ["Land"] = "Land|Water|Seabed",
                        ["Water"] = "Land|Water|Seabed",
                    },
                    ["FiringRandomness"] = 0.2,
                    ["FiringTolerance"] = 2,
                    ["Label"] = "MainGun",
                    ["MaxRadius"] = 70,
                    ["MuzzleSalvoDelay"] = 0.33,
                    ["MuzzleSalvoSize"] = 15,
                    ["MuzzleVelocity"] = 32,
                    ["ProjectileId"] = "/projectiles/TDFHeavyPlasmaGatlingCannon01/TDFHeavyPlasmaGatlingCannon01_proj.bp",
                    ["ProjectileLifetimeUsesMultiplier"] = 1.15,
                    ["ProjectilesPerOnFire"] = 1,
                    ["RackBones"] = {
                        [1] = {
                            ["MuzzleBones"] = {
                                [1] = "Gun_Muzzle",
                            },
                            ["RackBone"] = "Gun_Barrel",
                        },
                    },
                    ["RackFireTogether"] = false,
                    ["RackRecoilDistance"] = 0,
                    ["RackReloadTimeout"] = 10,
                    ["RackSalvoChargeTime"] = 2,
                    ["RackSalvoReloadTime"] = 3,
                    ["RackSalvoSize"] = 1,
                    ["RackSlavedToTurret"] = false,
                    ["RangeCategory"] = "UWRC_DirectFire",
                    ["RateOfFire"] = 1,
                    ["TargetCheckInterval"] = 0.25,
                    ["TargetPriorities"] = {
                        [1] = "SPECIALHIGHPRI",
                        [2] = "MOBILE",
                        [3] = "STRUCTURE DEFENSE",
                        [4] = "SPECIALLOWPRI",
                        [5] = "ALLUNITS",
                    },
                    ["TargetRestrictDisallow"] = "UNTARGETABLE",
                    ["TrackingRadius"] = 1.15,
                    ["TurretBoneMuzzle"] = "Muzzle",
                    ["TurretBonePitch"] = "Turret_Barrel",
                    ["TurretBoneYaw"] = "Turret",
                    ["TurretDualManipulators"] = false,
                    ["TurretPitch"] = 0,
                    ["TurretPitchRange"] = 60,
                    ["TurretPitchSpeed"] = 30,
                    ["TurretYaw"] = 0,
                    ["TurretYawRange"] = 180,
                    ["TurretYawSpeed"] = 35,
                    ["Turreted"] = true,
                    ["WeaponCategory"] = "Direct Fire",
                    ["WeaponRepackTimeout"] = 3,
                    ["WeaponUnpacks"] = true,
                },
            },
            ["targetId"] = "ues5042",
            ["unsupportedWeaponBindings"] = {},
        },
        ["scoSourceDynamicVisuals"] = {
            ["barrel"] = {
                ["acceleration"] = 180,
                ["axis"] = "z",
                ["bone"] = "Gun_Barrel",
                ["chargeSeconds"] = 2,
                ["chargeSpeed"] = 500,
                ["constructorGoal"] = 60,
                ["initialSpeed"] = 270,
                ["label"] = "MainGun",
                ["packedSpeed"] = 0,
                ["reloadSeconds"] = 3,
                ["reloadSpeed"] = 200,
                ["repackSeconds"] = 3,
                ["steamBone"] = "Exhaust",
                ["steamGraph"] = {
                    ["emitters"] = {
                        [1] = {
                            ["archive"] = "effects.scd",
                            ["coordinateContract"] = "FA mobile world XYZ retained; source size is treated as radius and doubled for native diameter (inference; retail shader source unavailable)",
                            ["limitations"] = {
                                [1] = "source color ramp sampled at native Unity gradient limit of eight keys; varying ramp row selection uses authored initial row",
                            },
                            ["nativeMaterial"] = "VFX/SCOM/Source/Materials/364f152636bb56a0e777.sanmaterial",
                            ["path"] = "effects/Emitters/weapon_mist_01_emit.bp",
                            ["ramp"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/ramp_white_02.dds",
                                ["sha256"] = "1f99980d014fae877ec70f47b15674b4a58b848e45b2429e4fa6a4f141dcd537",
                            },
                            ["scale"] = 1,
                            ["sha256"] = "48315933b3bc7a624b9bb39e90218a181529369c9c6483b75d330f4b7e42fda3",
                            ["sourceBlueprint"] = {
                                ["AlignRotation"] = false,
                                ["AlignToBone"] = false,
                                ["Blendmode"] = 3,
                                ["BlueprintId"] = "weapon_mist_01",
                                ["CatchupEmit"] = true,
                                ["CreateIfVisible"] = false,
                                ["EmitIfVisible"] = true,
                                ["EmitRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 0.5,
                                            ["z"] = 0,
                                        },
                                        [2] = {
                                            ["x"] = 150,
                                            ["y"] = 0.25,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["EndSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 73.8,
                                            ["y"] = 0.25,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["Flat"] = false,
                                ["FrameRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 1,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["Gravity"] = false,
                                ["InitialRotationCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 68.28,
                                            ["y"] = 180,
                                            ["z"] = 360,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["InterpolateEmission"] = true,
                                ["LODCutoff"] = 100,
                                ["Lifetime"] = 20,
                                ["LifetimeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 0,
                                            ["y"] = 27.778,
                                            ["z"] = 10,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["LocalAcceleration"] = false,
                                ["LocalVelocity"] = false,
                                ["OnlyEmitOnWater"] = false,
                                ["RampSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 73.95,
                                            ["y"] = 1.5,
                                            ["z"] = 3,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["RampTexture"] = "/textures/particles/ramp_white_02.dds",
                                ["Repeattime"] = 20,
                                ["RotationRateCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["SizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 76.979,
                                            ["y"] = 0.3,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["SnapToWaterline"] = false,
                                ["SortOrder"] = 10,
                                ["StartSizeCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 79.354,
                                            ["y"] = 0.154,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["Texture"] = "/textures/particles/cloud_smoke_alpha_10.dds",
                                ["TextureFramecount"] = 1,
                                ["TextureSelectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["TextureStripcount"] = 1,
                                ["VelocityCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75.39,
                                            ["y"] = 0.83,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["XAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["XDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 74.406,
                                            ["y"] = 0,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["XPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 0,
                                            ["z"] = 0.1,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["YAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["YDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 74.604,
                                            ["y"] = 0.05,
                                            ["z"] = 0.1,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["YPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 74.604,
                                            ["y"] = 0,
                                            ["z"] = 0.2,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["ZAccelCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 0,
                                            ["z"] = 0,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["ZDirectionCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 84.301,
                                            ["y"] = 0,
                                            ["z"] = 0.01,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                                ["ZPosCurve"] = {
                                    ["Keys"] = {
                                        [1] = {
                                            ["x"] = 75,
                                            ["y"] = 0,
                                            ["z"] = 0.1,
                                        },
                                    },
                                    ["XRange"] = 150,
                                },
                            },
                            ["texture"] = {
                                ["archive"] = "textures.scd",
                                ["path"] = "textures/particles/cloud_smoke_alpha_10.dds",
                                ["sha256"] = "291ce99308f3a59abf7498f3cb8889811bbc7f561493bbc44e84cf18571c831a",
                            },
                            ["timeUnits"] = {
                                ["accelerationMultiplier"] = 100,
                                ["rateMultiplier"] = 10,
                                ["reference"] = "https://wiki.faforever.com/en/Development/Modding/Modding_Emitters",
                                ["secondsPerTick"] = 0.1,
                                ["source"] = "ticks",
                            },
                        },
                    },
                    ["path"] = "VFX/SCOM/Source/ues5042/dynamic_steam.sanvfx",
                    ["sha256"] = "f26ccbc5a1bfec322d928e03cabb150435cbf8841357892c584c670cbac65383",
                },
                ["steamLifetime"] = 5.2778,
                ["weaponUnpacks"] = true,
            },
            ["sourceBlueprintSha256"] = "44010918c0950cf314a8fb013742976f0fe164f32ceeb4d0c7116d3c0b0869de",
            ["sourceId"] = "XEB2306",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 62083,
                ["entry"] = "units/XEB2306/XEB2306_lod0.scm",
                ["sha256"] = "decdf6e9fc34a479b1b47b82eccfbd2a6384304e7579a22a1f93fb3b826a4463",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 2251,
                ["entry"] = "units/XEB2306/XEB2306_Script.lua",
                ["sha256"] = "479939bdb84ccc7e13fdd0e776c5cb54e6c79397a26285c6c56be930adf408e5",
            },
            ["targetId"] = "ues5042",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.3,
            ["y"] = 1.3,
            ["z"] = 1.3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 7500,
            ["regen"] = 0,
            ["value"] = 7500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1500,
        ["cost"] = {
            ["alloys"] = 1800,
            ["energy"] = 16000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "Ravager",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 110,
        ["iconUIType"] = "land",
        ["name"] = "Ravager",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["tpId"] = "ues5042",
    },
    ["intel"] = {
        ["visionRadius"] = 24,
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 70,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 24,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "EDA",
        [3] = "SCFA_ALLUNITS",
        [4] = "SCFA_BUILTBYTIER3COMMANDER",
        [5] = "SCFA_BUILTBYTIER3ENGINEER",
        [6] = "SCFA_DEFENSE",
        [7] = "SCFA_DIRECTFIRE",
        [8] = "SCFA_DRAGBUILD",
        [9] = "SCFA_OVERLAYDIRECTFIRE",
        [10] = "SCFA_PRODUCTFA",
        [11] = "SCFA_RECLAIMABLE",
        [12] = "SCFA_SELECTABLE",
        [13] = "SCFA_SIZE12",
        [14] = "SCFA_SORTDEFENSE",
        [15] = "SCFA_STRUCTURE",
        [16] = "SCFA_TECH3",
        [17] = "SCFA_UEF",
        [18] = "SCFA_VISIBLETORECON",
        [19] = "STRUCTURE",
        [20] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5042/LOD0/ues5042.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues5042/LOD0/ues5042.sananimation",
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
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.23399999999999999,
                    ["y"] = 0.325,
                    ["z"] = -0.26,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.28600000000000003,
                    ["y"] = 0.23399999999999999,
                    ["z"] = 0.23399999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.26,
                    ["y"] = 0.36400000000000005,
                    ["z"] = 0.20800000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.23399999999999999,
                    ["y"] = 0.546,
                    ["z"] = -0.26,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.28600000000000003,
                    ["y"] = 0.52,
                    ["z"] = 0.23399999999999999,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 82,
            ["lod1distance"] = 215,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 0.85,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Gun_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 60,
                    ["pitchMin"] = -60,
                    ["pitchSpeed"] = 30,
                    ["projectileSpeed"] = 32,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 35,
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 175,
            ["damageFriendly"] = false,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ues5042/muzzle_maingun.sanvfx",
            },
            ["firingRandomness"] = 0.2,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 2,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Gun_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0.33,
            ["muzzleSalvoSize"] = 15,
            ["muzzles"] = {
                ["Gun_Muzzle"] = {
                    ["aimController"] = "Gun_Muzzle",
                },
            },
            ["name"] = "MainGun",
            ["projectileLifetime"] = 10,
            ["projectileTemplate"] = "psf0030",
            ["rangeMax"] = 70,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 1,
            ["scoFaSourceWeapon"] = {
                ["AboveWaterTargetsOnly"] = true,
                ["AimsStraightOnDisable"] = true,
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "XEL_Weapons",
                        ["Cue"] = "XEB2306_Gatling_Gun",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["CollideFriendly"] = false,
                ["Damage"] = 175,
                ["DamageRadius"] = 1,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Heavy Plasma Gatling Cannon",
                ["EnergyDrainPerSecond"] = 50,
                ["EnergyRequired"] = 50,
                ["FireTargetLayerCapsTable"] = {
                    ["Land"] = "Land|Water|Seabed",
                    ["Water"] = "Land|Water|Seabed",
                },
                ["FiringRandomness"] = 0.2,
                ["FiringTolerance"] = 2,
                ["Label"] = "MainGun",
                ["MaxRadius"] = 70,
                ["MuzzleSalvoDelay"] = 0.33,
                ["MuzzleSalvoSize"] = 15,
                ["MuzzleVelocity"] = 32,
                ["ProjectileId"] = "/projectiles/TDFHeavyPlasmaGatlingCannon01/TDFHeavyPlasmaGatlingCannon01_proj.bp",
                ["ProjectileLifetimeUsesMultiplier"] = 1.15,
                ["ProjectilesPerOnFire"] = 1,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Gun_Muzzle",
                        },
                        ["RackBone"] = "Gun_Barrel",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = 0,
                ["RackReloadTimeout"] = 10,
                ["RackSalvoChargeTime"] = 2,
                ["RackSalvoReloadTime"] = 3,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RangeCategory"] = "UWRC_DirectFire",
                ["RateOfFire"] = 1,
                ["TargetCheckInterval"] = 0.25,
                ["TargetPriorities"] = {
                    [1] = "SPECIALHIGHPRI",
                    [2] = "MOBILE",
                    [3] = "STRUCTURE DEFENSE",
                    [4] = "SPECIALLOWPRI",
                    [5] = "ALLUNITS",
                },
                ["TargetRestrictDisallow"] = "UNTARGETABLE",
                ["TrackingRadius"] = 1.15,
                ["TurretBoneMuzzle"] = "Muzzle",
                ["TurretBonePitch"] = "Turret_Barrel",
                ["TurretBoneYaw"] = "Turret",
                ["TurretDualManipulators"] = false,
                ["TurretPitch"] = 0,
                ["TurretPitchRange"] = 60,
                ["TurretPitchSpeed"] = 30,
                ["TurretYaw"] = 0,
                ["TurretYawRange"] = 180,
                ["TurretYawSpeed"] = 35,
                ["Turreted"] = true,
                ["WeaponCategory"] = "Direct Fire",
                ["WeaponRepackTimeout"] = 3,
                ["WeaponUnpacks"] = true,
            },
            ["scoFaSourceWeaponIndex"] = 1,
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "MainGun",
            },
        },
    },
}
