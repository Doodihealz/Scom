-- ucs3401: Radiance
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["auditedLimitation"] = "Retail UAB4301 shares UAB4202_Aopen.sca, but that clip is absent from every installed FA gamedata archive; no AnimOpen is required or invented.",
            ["deathClip"] = {
                ["durationSeconds"] = 2.8,
                ["key"] = "source_animadeath",
                ["rate"] = 0.5,
            },
            ["kind"] = "shield_rotators_t3",
            ["mapping"] = "UAB4301 -> ucs3401",
            ["rotatorCount"] = 2,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4301/UAB4301_unit.bp",
            ["sourceBlueprintSha256"] = "10a69396b3f055763593e01f361fd6fd53b804707e92fc745607aa02e0122f0a",
            ["sourceClips"] = {
                [1] = {
                    ["durationSeconds"] = 2.8,
                    ["frames"] = 29,
                    ["key"] = "source_animadeath",
                    ["name"] = "AnimAdeath",
                    ["rate"] = 0.5,
                    ["role"] = "death",
                    ["sha256"] = "44a21eabe955c1c078777d1886937648ca1608627412f79006eb23a8ac009d59",
                    ["source"] = "units/UAB4301/UAB4301_Adeath.sca",
                },
            },
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "4bc07a7ab33d9924dc8f5f8cd7c35e8d5918e48c7999fb651ce703f5e7b6b584",
            ["sourceScript"] = "units/UAB4301/UAB4301_script.lua",
            ["sourceScriptSha256"] = "1316a0c2e7a41408e681d3eff2a3be96794395132798e47d40a77e80f4367f41",
            ["stateOwner"] = "Rest remains the stable open baseline. Effective shield-up accelerates Pod/z to +60 at 50 deg/s^2 and Orb/y,z to -45,+45 at 45 deg/s^2; shield-down decelerates all to zero. AnimAdeath samples at source rate 0.5 before stock wreck/delete.",
            ["targetAnimation"] = {
                ["bytes"] = 20896,
                ["path"] = "Units/ucs3401/LOD0/ucs3401.sananimation",
                ["sha256"] = "c3a652b21a968437ecc3ff793087edd62c67bb2b31782fdc3510990fd1ca07c7",
            },
            ["targetClipCount"] = 2,
            ["targetModel"] = {
                ["bytes"] = 376801,
                ["path"] = "Units/ucs3401/LOD0/ucs3401_lod0.sanmodel",
                ["sha256"] = "6c3d9fab3912c82b0ad0a537209089846a740d50030f150f86060199dbc389d6",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 2956,
                ["path"] = "Units/ucs3401/LOD0/ucs3401.sanskeleton",
                ["sha256"] = "cb8056848ae2b221b6d3791fc8cb0f9d85588ce2ba7b1aecf121558182708066",
            },
            ["version"] = "1.0.2",
        },
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
                    ["x"] = 3,
                    ["z"] = 3,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -1.5,
                    ["offsetZ"] = -1.5,
                    ["sizeX"] = 6,
                    ["sizeZ"] = 6,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = true,
                ["energyDrainRechargeTime"] = 5,
                ["maxHealth"] = 18000,
                ["rechargeTime"] = 24,
                ["regenRate"] = 150,
                ["regenStartTime"] = 1,
                ["runtimeRadius"] = 17.5,
                ["size"] = 35,
                ["verticalOffset"] = -5,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB4301/UAB4301_unit.bp",
            ["sourceBlueprintSha256"] = "10a69396b3f055763593e01f361fd6fd53b804707e92fc745607aa02e0122f0a",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3COMMANDER",
                [3] = "BUILTBYTIER3ENGINEER",
                [4] = "DEFENSE",
                [5] = "DRAGBUILD",
                [6] = "OVERLAYDEFENSE",
                [7] = "PRODUCTSC1",
                [8] = "RECLAIMABLE",
                [9] = "SELECTABLE",
                [10] = "SHIELD",
                [11] = "SIZE12",
                [12] = "SORTDEFENSE",
                [13] = "STRUCTURE",
                [14] = "TECH3",
                [15] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB4301",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3401",
            ["weapons"] = {},
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Pod",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "Orb",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixShieldGeneratorPalette"] = {
            ["effect"] = "VFX/SCOM/FieldFixes/Shields/aeon_core_t3.sanvfx",
            ["faction"] = "aeon",
            ["positionOffset"] = {
                ["x"] = 0,
                ["y"] = -0.4750256,
                ["z"] = -6e-07,
            },
            ["sourceEffect"] = "VFX/Unit/vcu1221_active_shield_generator.sanvfx",
            ["tier"] = 3,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 1.5,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 1.75,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.3,
            ["y"] = 4,
            ["z"] = 2.3,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 300,
            ["regen"] = 0,
            ["value"] = 300,
        },
        ["shields"] = {
            [1] = {
                ["audio"] = {
                    ["active"] = {
                        ["looping"] = true,
                        ["name"] = "aclu2130",
                    },
                    ["onImpact"] = {
                        ["looping"] = false,
                        ["name"] = "acoi0025",
                    },
                },
                ["boneName"] = "Root",
                ["effectsPersistent"] = {
                    [1] = {
                        ["boneName"] = "Root",
                        ["particleName"] = "VFX/SCOM/FieldFixes/Shields/aeon_core_t3.sanvfx",
                        ["positionOffset"] = {
                            ["x"] = 0,
                            ["y"] = -0.4750256,
                            ["z"] = -6e-07,
                        },
                    },
                },
                ["max"] = 18000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["y"] = -5,
                },
                ["radii"] = {
                    ["x"] = 17.5,
                    ["y"] = 17.5,
                    ["z"] = 17.5,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 24,
                ["regen"] = 150,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 18000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 3000,
        ["cost"] = {
            ["alloys"] = 2400,
            ["energy"] = 44000,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 300,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Radiance",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Radiance",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "ucs3401",
        ["unitTypeName"] = "Radiance",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
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
    ["skirtSize"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "CHOSEN",
        [3] = "DEFENCE",
        [4] = "SHIELD",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DEFENSE",
        [12] = "SCFA_DRAGBUILD",
        [13] = "SCFA_OVERLAYDEFENSE",
        [14] = "SCFA_PRODUCTSC1",
        [15] = "SCFA_RECLAIMABLE",
        [16] = "SCFA_SELECTABLE",
        [17] = "SCFA_SHIELD",
        [18] = "SCFA_SIZE12",
        [19] = "SCFA_SORTDEFENSE",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH3",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3401/LOD0/ucs3401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3401/LOD0/ucs3401.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
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
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.414,
                    ["y"] = 2.75,
                    ["z"] = -0.45999999999999996,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.506,
                    ["y"] = 2.4699999999999998,
                    ["z"] = 0.414,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.45999999999999996,
                    ["y"] = 2.87,
                    ["z"] = 0.368,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.414,
                    ["y"] = 3.4299999999999997,
                    ["z"] = -0.45999999999999996,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.506,
                    ["y"] = 3.35,
                    ["z"] = 0.414,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 99,
            ["lod1distance"] = 257,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.5,
                ["y"] = 1.5,
            },
        },
    },
}
