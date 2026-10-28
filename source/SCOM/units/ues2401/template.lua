-- ues2401: SD - Pulse
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorShieldLoopRetained"] = false,
            ["mapping"] = "UEB4202 -> ues2401",
            ["modelSafeShieldAnchorUsed"] = true,
            ["progressionSubstitution"] = "ues3401/UEB4301",
            ["sanctuaryDamageRechargeHPRatio"] = 1,
            ["sanctuaryRegenAssistMultiplierSupported"] = false,
            ["sanctuaryShieldRadius"] = 13,
            ["sanctuaryUpgradesTo"] = "ues3401",
            ["separateEnergyDrainRechargeSupported"] = true,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEB4202/UEB4202_unit.bp",
            ["sourceBlueprintSha256"] = "7b9219f640e6034389a5945c71d4d5b90d29f134a51e3a102d93b79003f6df56",
            ["sourceDamageRechargeRestoresFullHealth"] = true,
            ["sourceEmitterGraphSupported"] = false,
            ["sourceRegenAssistMultiplier"] = 60,
            ["sourceScript"] = "units/UEB4202/UEB4202_script.lua",
            ["sourceScriptSha256"] = "ef4fddb1e0b30e8b686c542f70375346224ab98b1d124b55c2b0991a2b6cae93",
            ["sourceShieldAudioBanksImported"] = false,
            ["sourceShieldEnergyDrainRechargeTime"] = 5,
            ["sourceShieldSizeDiameter"] = 26,
            ["sourceShieldVerticalOffset"] = -3,
            ["sourceSkirtOffsetSupported"] = false,
            ["sourceUpgradesTo"] = "UEB4301",
        },
        ["faSupportShield"] = {
            ["energyDrainRechargeTime"] = 5,
            ["generatorCore"] = {
                ["boneName"] = "Root",
                ["effect"] = "VFX/SCOM/FieldFixes/Shields/uef_core_t2.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 2.9,
                },
                ["rotatesWithMechanicalAnchor"] = false,
                ["sourceEffect"] = "VFX/Unit/veu1221_active_shield_generator.sanvfx",
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
            ["sourceUpgradeSpinDown"] = true,
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
            ["upgradeRotatorSpeeds"] = {
                [1] = {
                    ["x"] = 0,
                    ["y"] = 90,
                    ["z"] = 0,
                },
                [2] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 90,
                },
            },
        },
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "upgrade",
            ["durationSeconds"] = 9,
            ["restAnimationKey"] = "walk",
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
                ["z"] = 0.32,
            },
            ["size"] = {
                ["x"] = 3.8,
                ["y"] = 3.4,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 3.6,
            ["y"] = 3.2,
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
            ["z"] = 0.32,
        },
        ["collisionSize"] = {
            ["x"] = 3.8,
            ["y"] = 4.5,
            ["z"] = 3.4,
        },
    },
    ["construction"] = {
        ["buildPower"] = 15,
        ["canBuild"] = "(Tags.ues3401) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "ues3401",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 250,
            ["regen"] = 0,
            ["value"] = 250,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["effectsPersistent"] = {
                    [1] = {
                        ["boneName"] = "Root",
                        ["particleName"] = "VFX/SCOM/FieldFixes/Shields/uef_core_t2.sanvfx",
                        ["positionOffset"] = {
                            ["x"] = 0,
                            ["y"] = 0,
                            ["z"] = 2.9,
                        },
                    },
                },
                ["max"] = 9000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = -0.0013564,
                    ["y"] = 2.0057951,
                    ["z"] = 0.0040371,
                },
                ["radii"] = {
                    ["x"] = 13,
                    ["y"] = 13,
                    ["z"] = 13,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 15,
                ["regen"] = 120,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 9000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 600,
        ["cost"] = {
            ["alloys"] = 600,
            ["energy"] = 6000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 200,
        },
    },
    ["footprint"] = {
        ["x"] = 3.8,
        ["y"] = 3.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAImportedAnimatedStructure",
        },
        ["displayName"] = "SD - Pulse",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "SD - Pulse",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Shield"] = true,
        },
        ["tpId"] = "ues2401",
        ["unitTypeName"] = "EDAT2Shield",
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
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "CONSTRUCTION",
        [4] = "DEFENCE",
        [5] = "EDA",
        [6] = "SHIELD",
        [7] = "STRUCTURE",
        [8] = "TECH2",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DEFENSE",
        [15] = "SCFA_DRAGBUILD",
        [16] = "SCFA_OVERLAYDEFENSE",
        [17] = "SCFA_PRODUCTSC1",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SHIELD",
        [21] = "SCFA_SIZE12",
        [22] = "SCFA_SORTDEFENSE",
        [23] = "SCFA_STRUCTURE",
        [24] = "SCFA_TECH2",
        [25] = "SCFA_UEF",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["upgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2401/LOD0/ues2401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ues2401/LOD0/ues2401.sananimation",
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
                    ["particleName"] = "VFX/Death/ved2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6839999999999999,
                    ["y"] = 3.175,
                    ["z"] = -0.36000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.836,
                    ["y"] = 2.86,
                    ["z"] = 0.9319999999999999,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.76,
                    ["y"] = 3.31,
                    ["z"] = 0.8640000000000001,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.6839999999999999,
                    ["y"] = 3.9399999999999995,
                    ["z"] = -0.36000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.836,
                    ["y"] = 3.8499999999999996,
                    ["z"] = 0.9319999999999999,
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
                ["z"] = 0.32,
            },
            ["size"] = {
                ["x"] = 3.8,
                ["y"] = 3.4,
            },
        },
    },
}
