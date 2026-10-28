-- ucs2701: Radar System
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "intel_rotor_pair_upgrade",
            ["mapping"] = "UAB3201 -> ucs2701",
            ["rotatorCount"] = 2,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB3201/UAB3201_unit.bp",
            ["sourceBlueprintSha256"] = "1e03af433f4bdd50b7de22a2f4c53053c8b3551eb85b542336f4d3ce74611ea3",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 4.5,
                    ["frames"] = 46,
                    ["key"] = "source_animupgrade",
                    ["name"] = "AnimUpgrade",
                    ["rate"] = 1,
                    ["role"] = "upgrade",
                    ["sha256"] = "c76fac253a891aca0b1656af1c96968badace7995b2209496a1f4487d1acf207",
                    ["source"] = "units/UAB3201/UAB3201_Aupgrade.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "a7e5c3ab944175b5540d1f16a291f474d199ac3a2f177f1c5598de2ce9344fdd",
            ["sourceScript"] = "units/UAB3201/UAB3201_script.lua",
            ["sourceScriptSha256"] = "43c3ee2e7594ed1013945c96c281a0c608a4a7254e7c281089d0b2a9560b3513",
            ["stateOwner"] = "Effective radarDetector enabled y-speeds accelerate at 20 to 30/60; player toggle or energy outage spins both down at 60. AnimUpgrade is progress-bound.",
            ["targetAnimation"] = {
                ["bytes"] = 53135,
                ["path"] = "Units/ucs2701/LOD0/ucs2701.sananimation",
                ["sha256"] = "6067de22f05acda7607db8c0a2ce5617557630d3e6182b463b7cfca8104951b2",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 324137,
                ["path"] = "Units/ucs2701/LOD0/ucs2701_lod0.sanmodel",
                ["sha256"] = "3b511e61ab942fb059b8ce36b35dd57960fc800913902c6734635c3d4ca2cc38",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 7182,
                ["path"] = "Units/ucs2701/LOD0/ucs2701.sanskeleton",
                ["sha256"] = "8f7aad8c73858a0881913aaf889b6cdb928f8713b46c39f22a9f918684e8e0c3",
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
                    ["radarRadius"] = 200,
                    ["visionRadius"] = 25,
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
            ["sourceBlueprint"] = "units/UAB3201/UAB3201_unit.bp",
            ["sourceBlueprintSha256"] = "1e03af433f4bdd50b7de22a2f4c53053c8b3551eb85b542336f4d3ce74611ea3",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER2COMMANDER",
                [3] = "BUILTBYTIER2ENGINEER",
                [4] = "BUILTBYTIER3COMMANDER",
                [5] = "BUILTBYTIER3ENGINEER",
                [6] = "DRAGBUILD",
                [7] = "INTELLIGENCE",
                [8] = "OVERLAYRADAR",
                [9] = "PRODUCTSC1",
                [10] = "RADAR",
                [11] = "RECLAIMABLE",
                [12] = "SELECTABLE",
                [13] = "SHOWQUEUE",
                [14] = "SIZE4",
                [15] = "SORTINTEL",
                [16] = "STRUCTURE",
                [17] = "TECH2",
                [18] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB3201",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB3101",
            ["sourceUpgradeTo"] = "UAB3104",
            ["targetId"] = "ucs2701",
            ["weapons"] = {},
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animupgrade",
            ["durationSeconds"] = 4.5,
            ["restAnimationKey"] = "walk",
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "B02",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [2] = {
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
            ["target"] = "ucs3701",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.8,
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
            ["y"] = 0.8,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 2.1,
            ["z"] = 0.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.ucs3701) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ucs3701",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 50,
            ["regen"] = 0,
            ["value"] = 50,
        },
    },
    ["economy"] = {
        ["buildTime"] = 600,
        ["cost"] = {
            ["alloys"] = 180,
            ["energy"] = 3600,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 250,
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
        ["tpId"] = "ucs2701",
        ["unitTypeName"] = "Radar System",
    },
    ["intel"] = {
        ["radarRadius"] = 200,
        ["visionRadius"] = 25,
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 200,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 25,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CHOSEN",
        [4] = "INTEL",
        [5] = "RADAR",
        [6] = "STRUCTURE",
        [7] = "TECH2",
        [8] = "SCFA_AEON",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_INTELLIGENCE",
        [16] = "SCFA_OVERLAYRADAR",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RADAR",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SHOWQUEUE",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTINTEL",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animupgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2701/LOD0/ucs2701.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2701/LOD0/ucs2701.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 1.3250000000000002,
                    ["z"] = -0.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 1.178,
                    ["z"] = 0.09,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 1.3880000000000001,
                    ["z"] = 0.08,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 1.682,
                    ["z"] = -0.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 1.6400000000000001,
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
                ["y"] = 0.8,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
            },
        },
    },
}
