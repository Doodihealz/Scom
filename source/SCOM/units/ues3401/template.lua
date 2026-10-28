-- ues3401: HSD Pulse
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorShieldLoopRetained"] = false,
            ["mapping"] = "UEB4301 -> ues3401",
            ["modelSafeShieldAnchorUsed"] = true,
            ["sanctuaryDamageRechargeHPRatio"] = 1,
            ["sanctuaryRegenAssistMultiplierSupported"] = false,
            ["sanctuaryShieldRadius"] = 22,
            ["separateEnergyDrainRechargeSupported"] = true,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB4301/UEB4301_unit.bp",
            ["sourceBlueprintSha256"] = "8e86fefc485a76ad1aa1e55894d0dbb3823cec2f58b175dccfbc6d67c6b67e78",
            ["sourceDamageRechargeRestoresFullHealth"] = true,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceRegenAssistMultiplier"] = 60,
            ["sourceScript"] = "units/UEB4301/UEB4301_script.lua",
            ["sourceScriptSha256"] = "67abce0dbcd88803957cdad1a01a6e0931a553fcfa583083e682d238ee0a0bd9",
            ["sourceShieldAudioBanksImported"] = false,
            ["sourceShieldEnergyDrainRechargeTime"] = 5,
            ["sourceShieldSizeDiameter"] = 44,
            ["sourceShieldVerticalOffset"] = -6,
            ["sourceSkirtOffsetSupported"] = false,
        },
        ["faSupportShield"] = {
            ["energyDrainRechargeTime"] = 5,
            ["generatorCore"] = {
                ["boneName"] = "Root",
                ["effect"] = "VFX/SCOM/FieldFixes/Shields/uef_core_t3.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 2.9,
                },
                ["rotatesWithMechanicalAnchor"] = false,
                ["sourceEffect"] = "VFX/Unit/veu1222_active_shield_generator.sanvfx",
                ["visibleTransformScale"] = 0.3,
            },
            ["initialRotatorSpeeds"] = {
                [1] = {
                    ["x"] = 0,
                    ["y"] = 10,
                    ["z"] = 0,
                },
                [2] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -10,
                },
            },
            ["sanctuaryAccelerationSupported"] = false,
            ["sanctuarySpinDownSupported"] = false,
            ["sourceAcceleration"] = 5,
            ["sourceInitialSpeed"] = 10,
            ["sourceUpgradeSpinDown"] = false,
            ["steadyRotatorSpeeds"] = {
                [1] = {
                    ["x"] = 0,
                    ["y"] = 10,
                    ["z"] = 0,
                },
                [2] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -10,
                },
            },
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Spinner",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 10,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "B01",
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = -10,
                },
            },
        },
        ["scoFieldFixUniversalUef"] = "1.1.2",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2.05,
                ["z"] = -0.21,
            },
            ["size"] = {
                ["x"] = 4.4,
                ["y"] = 4.4,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 4.2,
            ["y"] = 4.2,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "aeod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 2.05,
            ["z"] = -0.21,
        },
        ["collisionSize"] = {
            ["x"] = 4.4,
            ["y"] = 4.5,
            ["z"] = 4.4,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["effectsPersistent"] = {
                    [1] = {
                        ["boneName"] = "Root",
                        ["particleName"] = "VFX/SCOM/FieldFixes/Shields/uef_core_t3.sanvfx",
                        ["positionOffset"] = {
                            ["x"] = 0,
                            ["y"] = 0,
                            ["z"] = 2.9,
                        },
                    },
                },
                ["max"] = 15000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = -0.0013564,
                    ["y"] = 2.0057951,
                    ["z"] = -5.9959629,
                },
                ["radii"] = {
                    ["x"] = 22,
                    ["y"] = 22,
                    ["z"] = 22,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 23,
                ["regen"] = 131,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 15000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 3750,
        ["cost"] = {
            ["alloys"] = 3000,
            ["energy"] = 50000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 400,
        },
    },
    ["footprint"] = {
        ["x"] = 4.4,
        ["y"] = 4.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAStructure",
        },
        ["displayName"] = "HSD Pulse",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "HSD Pulse",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "ues3401",
        ["unitTypeName"] = "EDAT3Shield",
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
        [2] = "DEFENCE",
        [3] = "EDA",
        [4] = "SHIELD",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DEFENSE",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_OVERLAYDEFENSE",
        [13] = "SCFA_PRODUCTSC1",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SHIELD",
        [17] = "SCFA_SIZE12",
        [18] = "SCFA_SORTDEFENSE",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH3",
        [21] = "SCFA_UEF",
        [22] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
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
                    ["particleName"] = "VFX/Death/ved2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.792,
                    ["y"] = 3.175,
                    ["z"] = -1.09,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.9680000000000001,
                    ["y"] = 2.86,
                    ["z"] = 0.5820000000000001,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.8800000000000001,
                    ["y"] = 3.31,
                    ["z"] = 0.4940000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.792,
                    ["y"] = 3.9399999999999995,
                    ["z"] = -1.09,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.9680000000000001,
                    ["y"] = 3.8499999999999996,
                    ["z"] = 0.5820000000000001,
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
                ["y"] = 2.05,
                ["z"] = -0.21,
            },
            ["size"] = {
                ["x"] = 4.4,
                ["y"] = 4.4,
            },
        },
    },
}
