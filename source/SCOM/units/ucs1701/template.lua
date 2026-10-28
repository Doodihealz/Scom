-- ucs1701: Radar System
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "intel_rotor_upgrade",
            ["mapping"] = "UAB3101 -> ucs1701",
            ["rotatorCount"] = 1,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB3101/UAB3101_unit.bp",
            ["sourceBlueprintSha256"] = "2e13daff88938b7da55e308ee696a4abcc2be3d01cd5023ecd32b79a4ae14262",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 4.5,
                    ["frames"] = 46,
                    ["key"] = "source_animupgrade",
                    ["name"] = "AnimUpgrade",
                    ["rate"] = 1,
                    ["role"] = "upgrade",
                    ["sha256"] = "2f0451c62a0a6d7b1ff2e280221317b8b33c45b8ee8efc5f0eb45689de623d4a",
                    ["source"] = "units/UAB3101/UAB3101_Aupgrade.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "86c9b17c95e3c24595bb447b783c0cb14c1bdfa075c68c2254e6d44b2f918a9f",
            ["sourceScript"] = "units/UAB3101/UAB3101_script.lua",
            ["sourceScriptSha256"] = "5ffb03c438f321daf46930a184989d6fa18d6121d50a5a103b4731051bf104e9",
            ["stateOwner"] = "Effective radarDetector enabled: B01/y accelerates at 20 to 30; player toggle or energy outage spins down at 20. AnimUpgrade is progress-bound and aim bones remain unowned.",
            ["targetAnimation"] = {
                ["bytes"] = 43269,
                ["path"] = "Units/ucs1701/LOD0/ucs1701.sananimation",
                ["sha256"] = "2d8f1094d84dc0f5f6c578401c1106c5b9f1c26a74702e4d03f5716d78602f66",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 252073,
                ["path"] = "Units/ucs1701/LOD0/ucs1701_lod0.sanmodel",
                ["sha256"] = "85bb6e169bf2b3cb026d6d0d78af13e14d1cd559eb8e717b235af02e2401e670",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 6256,
                ["path"] = "Units/ucs1701/LOD0/ucs1701.sanskeleton",
                ["sha256"] = "170aa863bead9aea62fc50112799ed33f35421cb36a093963ca5bfcbd29ba510",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["reactivateTime"] = 5,
                    ["showIntelOnSelect"] = true,
                },
                ["runtimeSupported"] = {
                    ["radarRadius"] = 115,
                    ["visionRadius"] = 20,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -0.5,
                    ["offsetZ"] = -0.5,
                    ["sizeX"] = 2,
                    ["sizeZ"] = 2,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB3101/UAB3101_unit.bp",
            ["sourceBlueprintSha256"] = "2e13daff88938b7da55e308ee696a4abcc2be3d01cd5023ecd32b79a4ae14262",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER1ENGINEER",
                [3] = "BUILTBYTIER2COMMANDER",
                [4] = "BUILTBYTIER2ENGINEER",
                [5] = "BUILTBYTIER3COMMANDER",
                [6] = "BUILTBYTIER3ENGINEER",
                [7] = "DRAGBUILD",
                [8] = "INTELLIGENCE",
                [9] = "OVERLAYRADAR",
                [10] = "PRODUCTSC1",
                [11] = "RADAR",
                [12] = "RECLAIMABLE",
                [13] = "SELECTABLE",
                [14] = "SHOWQUEUE",
                [15] = "SIZE4",
                [16] = "SORTINTEL",
                [17] = "STRUCTURE",
                [18] = "TECH1",
                [19] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB3101",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "UAB3201",
            ["targetId"] = "ucs1701",
            ["weapons"] = {},
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animupgrade",
            ["durationSeconds"] = 4.5,
            ["restAnimationKey"] = "walk",
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "B01",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixAeonUpgradeRouting"] = {
            ["target"] = "ucs2701",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.42500000000000004,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.42500000000000004,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 1.35,
            ["z"] = 0.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.ucs2701) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ucs2701",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10,
            ["regen"] = 0,
            ["value"] = 10,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80,
        ["cost"] = {
            ["alloys"] = 80,
            ["energy"] = 720,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 20,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Radar System",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Radar System",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs1701",
        ["unitTypeName"] = "Radar System",
    },
    ["intel"] = {
        ["radarRadius"] = 115,
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 115,
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
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CHOSEN",
        [5] = "INTEL",
        [6] = "RADAR",
        [7] = "STRUCTURE",
        [8] = "TECH1",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER1ENGINEER",
        [12] = "SCFA_BUILTBYTIER2COMMANDER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3COMMANDER",
        [15] = "SCFA_BUILTBYTIER3ENGINEER",
        [16] = "SCFA_DRAGBUILD",
        [17] = "SCFA_INTELLIGENCE",
        [18] = "SCFA_OVERLAYRADAR",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RADAR",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SHOWQUEUE",
        [24] = "SCFA_SIZE4",
        [25] = "SCFA_SORTINTEL",
        [26] = "SCFA_STRUCTURE",
        [27] = "SCFA_TECH1",
        [28] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animupgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1701/LOD0/ucs1701.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs1701/LOD0/ucs1701.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.7625000000000001,
                    ["z"] = -0.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.668,
                    ["z"] = 0.09,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.8030000000000002,
                    ["z"] = 0.08,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.9920000000000001,
                    ["z"] = -0.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.9650000000000001,
                    ["z"] = 0.09,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 175,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.42500000000000004,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
            },
        },
    },
}
