-- ucl2501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonEngineerBuildAnimation"] = {
            ["animationKey"] = "build",
            ["authoredRate"] = 1,
            ["durationSeconds"] = 1.6666666269302368,
            ["restAnimationKey"] = "walk",
        },
        ["buildBeamBones"] = {
            [1] = "Muzzle",
        },
        ["buildBeamEffectName"] = "beam1",
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
                    ["x"] = 1,
                    ["z"] = 0.8,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0208/UAL0208_unit.bp",
            ["sourceBlueprintSha256"] = "493b427a1d15e2231537c86ce443e413ec43816e96676573b6dc97c5d747ef92",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2FACTORY",
                [3] = "BUILTBYTIER3FACTORY",
                [4] = "CAPTURE",
                [5] = "CONSTRUCTION",
                [6] = "ENGINEER",
                [7] = "HOVER",
                [8] = "LAND",
                [9] = "MOBILE",
                [10] = "PATROLHELPER",
                [11] = "PRODUCTSC1",
                [12] = "RECLAIM",
                [13] = "RECLAIMABLE",
                [14] = "REPAIR",
                [15] = "SELECTABLE",
                [16] = "SHOWQUEUE",
                [17] = "TECH2",
                [18] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0.5,
            ["sourceId"] = "UAL0208",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 1.9,
            ["sourceMotionType"] = "RULEUMT_Hover",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl2501",
            ["weapons"] = {},
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -6.740810931660237e-10,
                [2] = 0.3636226654052731,
                [3] = 2.2367662003791994e-09,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 2,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0208",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 54086,
                ["entry"] = "units/UAL0208/UAL0208_lod0.scm",
                ["sha256"] = "b917546718e78d9aa50103da754e2ff9bb4aadc27cd55e1cba24356c2c6f4e0a",
            },
        },
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15000000000000002,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.6,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1410",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.15000000000000002,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 0.8,
            ["z"] = 0.8,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T2_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 620,
            ["regen"] = 0,
            ["value"] = 620,
        },
    },
    ["economy"] = {
        ["buildTime"] = 800,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 840,
        },
        ["storage"] = {
            ["alloys"] = 20,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 0.8,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortEngineer",
        },
        ["displayName"] = "Engineer",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "engineer",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_land1_engineer.png",
        ["iconUIBuildSortPriority"] = 150,
        ["iconUIType"] = "amphibious",
        ["name"] = "Engineer",
        ["orders"] = {
            ["Assist"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Pause"] = false,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ucl2501",
        ["unitTypeName"] = "Engineer",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 1.9,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["deceleration"] = 1.9,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0.5,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 6,
        ["speed"] = 1.9,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
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
        [4] = "CONSTRUCTION",
        [5] = "ENGINEER",
        [6] = "HOVER",
        [7] = "LAND",
        [8] = "MOBILE",
        [9] = "TECH2",
        [10] = "SCFA_AEON",
        [11] = "SCFA_ALLUNITS",
        [12] = "SCFA_BUILTBYTIER2FACTORY",
        [13] = "SCFA_BUILTBYTIER3FACTORY",
        [14] = "SCFA_CAPTURE",
        [15] = "SCFA_CONSTRUCTION",
        [16] = "SCFA_ENGINEER",
        [17] = "SCFA_HOVER",
        [18] = "SCFA_LAND",
        [19] = "SCFA_MOBILE",
        [20] = "SCFA_PATROLHELPER",
        [21] = "SCFA_PRODUCTSC1",
        [22] = "SCFA_RECLAIM",
        [23] = "SCFA_RECLAIMABLE",
        [24] = "SCFA_REPAIR",
        [25] = "SCFA_SELECTABLE",
        [26] = "SCFA_SHOWQUEUE",
        [27] = "SCFA_TECH2",
        [28] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl2501/LOD0/ucl2501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl2501/LOD0/ucl2501.sananimation",
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
                    ["x"] = 0.18,
                    ["y"] = 0.35000000000000003,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.29400000000000004,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.37400000000000005,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.48600000000000004,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.4700000000000001,
                    ["z"] = 0.144,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 173,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15000000000000002,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.6,
            },
        },
    },
}
