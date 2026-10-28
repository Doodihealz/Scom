-- ucl4401: Asylum
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 20,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.8,
                    ["z"] = 0.8,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = true,
                ["energyDrainRechargeTime"] = 5,
                ["maxHealth"] = 5000,
                ["rechargeTime"] = 26,
                ["regenRate"] = 65,
                ["regenStartTime"] = 1,
                ["runtimeRadius"] = 8,
                ["size"] = 16,
                ["verticalOffset"] = -3,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0307/UAL0307_unit.bp",
            ["sourceBlueprintSha256"] = "c4ceb4acc4ada9f5e88a4182e895873d9ae518a7cd3be1f2898690696f3a191b",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2FACTORY",
                [3] = "BUILTBYTIER3FACTORY",
                [4] = "DEFENSE",
                [5] = "HOVER",
                [6] = "LAND",
                [7] = "MOBILE",
                [8] = "OVERLAYDEFENSE",
                [9] = "PRODUCTSC1",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SHIELD",
                [13] = "TECH2",
                [14] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0.25,
            ["sourceId"] = "UAL0307",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 4,
            ["sourceMotionType"] = "RULEUMT_Hover",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl4401",
            ["weapons"] = {},
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = 4.76837158203125e-07,
                [2] = 0.3329230642319645,
                [3] = -5.451477133372289e-07,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0307",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 45894,
                ["entry"] = "units/UAL0307/UAL0307_LOD0.scm",
                ["sha256"] = "83cef1a21de286ac86f62824c04b013fcb3dde3794b87e434c1060c9070ba019",
            },
        },
        ["scoSourceSecondaryVisuals"] = {
            ["animationState"] = {
                ["clipName"] = "AnimOpen",
                ["condition"] = "shield",
                ["duration"] = 1,
                ["forwardRate"] = 1,
                ["key"] = "scoSecondaryOpen",
                ["reverseRate"] = -1,
                ["sanAnimationPath"] = "Units/ucl4401/LOD0/ucl4401.sananimation",
                ["source"] = {
                    ["archive"] = "units.scd",
                    ["bindPoseTracks"] = {},
                    ["blueprintUses"] = {
                        [1] = ".Display.AnimationOpen",
                    },
                    ["bytes"] = 6484,
                    ["clipName"] = "AnimOpen",
                    ["duration"] = 1,
                    ["entry"] = "units/UAL0307/UAL0307_Aopen.sca",
                    ["frames"] = 31,
                    ["outputDuration"] = 1,
                    ["scriptLiteralUse"] = false,
                    ["sha256"] = "be39787df5d59531ff3a41014004d0c054d74a847ec5f70a0a66f0bddc4bfbf8",
                    ["sourcePlaybackRateBaked"] = 1,
                    ["tracks"] = 7,
                    ["usedBySource"] = true,
                },
            },
            ["effects"] = {},
            ["meshes"] = {},
            ["sourceBlueprintSha256"] = "c4ceb4acc4ada9f5e88a4182e895873d9ae518a7cd3be1f2898690696f3a191b",
            ["sourceId"] = "UAL0307",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1916,
                ["entry"] = "units/UAL0307/UAL0307_script.lua",
                ["sha256"] = "4368d6b4f3d32011c9827a66df29b461dd6314fc6266bd1022bdb5ab6b3aeb90",
            },
            ["targetId"] = "ucl4401",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.55,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1144",
        },
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1440",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.8,
            ["y"] = 0.5,
            ["z"] = 0.8,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 100,
            ["regen"] = 0,
            ["value"] = 100,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["max"] = 5000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["y"] = -3,
                },
                ["radii"] = {
                    ["x"] = 8,
                    ["y"] = 8,
                    ["z"] = 8,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 26,
                ["regen"] = 65,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 5000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 720,
        ["cost"] = {
            ["alloys"] = 144,
            ["energy"] = 1080,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 125,
        },
    },
    ["footprint"] = {
        ["x"] = 0.8,
        ["y"] = 0.8,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortLandUnit",
        },
        ["displayName"] = "Asylum",
        ["icon"] = {
            ["shape"] = "experimental1",
            ["symbol"] = "shield",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_experimental1_shield.png",
        ["iconUIBuildSortPriority"] = 80,
        ["iconUIType"] = "land",
        ["name"] = "Asylum",
        ["orders"] = {
            ["Assist"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "ucl4401",
        ["unitTypeName"] = "Asylum",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 4,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandLarge",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandLarge",
            [2] = "Sea",
        },
        ["deceleration"] = 4,
        ["mass"] = 0,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0.25,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 150,
        ["sortOrder"] = 4,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_FACTORY",
        [2] = "BUILDABLE_BY_T3_FACTORY",
        [3] = "CHOSEN",
        [4] = "DEFENCE",
        [5] = "HOVER",
        [6] = "LAND",
        [7] = "MOBILE",
        [8] = "SHIELD",
        [9] = "TECH2",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_DEFENSE",
        [15] = "SCFA_HOVER",
        [16] = "SCFA_LAND",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_OVERLAYDEFENSE",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIMABLE",
        [21] = "SCFA_SELECTABLE",
        [22] = "SCFA_SHIELD",
        [23] = "SCFA_TECH2",
        [24] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["scoSecondaryOpen"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl4401/LOD0/ucl4401.sananimation",
            },
            ["source_animopen"] = {
                ["clipName"] = "AnimOpen",
                ["sanAnimationPath"] = "Units/ucl4401/LOD0/ucl4401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl4401/LOD0/ucl4401.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.375,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.33999999999999997,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.39,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.45999999999999996,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.45,
                    ["z"] = 0.144,
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
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.55,
                ["y"] = 0.55,
            },
        },
    },
}
