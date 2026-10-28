-- uss3401: Athanuhthe
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixShieldGeneratorPalette"] = {
            ["effect"] = "VFX/SCOM/FieldFixes/Shields/seraphim_core_t3.sanvfx",
            ["faction"] = "seraphim",
            ["positionOffset"] = {
                ["x"] = 0,
                ["y"] = -3.5,
                ["z"] = 0,
            },
            ["sourceEffect"] = "VFX/Unit/vcu1221_active_shield_generator.sanvfx",
            ["tier"] = 3,
            ["version"] = "1.0.0",
        },
        ["scoFieldFixShieldLifecycle"] = {
            ["activationAnimationKey"] = "source_animactivate",
            ["restAnimationKey"] = "walk",
            ["runtimeShieldLifecycleConsumerRequired"] = true,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.75,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1.0666667222976685,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
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
            ["max"] = 600,
            ["regen"] = 0,
            ["value"] = 600,
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
                        ["boneName"] = "Orb",
                        ["particleName"] = "VFX/SCOM/FieldFixes/Shields/seraphim_core_t3.sanvfx",
                        ["positionOffset"] = {
                            ["x"] = 0,
                            ["y"] = -3.5,
                            ["z"] = 0,
                        },
                    },
                },
                ["max"] = 21000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -7,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 23,
                    ["y"] = 23,
                    ["z"] = 23,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 25,
                ["regen"] = 168,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 21000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 4500,
        ["cost"] = {
            ["alloys"] = 3600,
            ["energy"] = 60000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 500,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Athanuhthe",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Athanuhthe",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Shield"] = true,
        },
        ["tpId"] = "uss3401",
        ["unitTypeName"] = "UnknownT3Shield",
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
        [3] = "SCFA_ALLUNITS",
        [4] = "SCFA_BUILTBYTIER3COMMANDER",
        [5] = "SCFA_BUILTBYTIER3ENGINEER",
        [6] = "SCFA_DEFENSE",
        [7] = "SCFA_DRAGBUILD",
        [8] = "SCFA_OVERLAYDEFENSE",
        [9] = "SCFA_PRODUCTFA",
        [10] = "SCFA_RECLAIMABLE",
        [11] = "SCFA_SELECTABLE",
        [12] = "SCFA_SERAPHIM",
        [13] = "SCFA_SHIELD",
        [14] = "SCFA_SIZE12",
        [15] = "SCFA_SORTDEFENSE",
        [16] = "SCFA_STRUCTURE",
        [17] = "SCFA_TECH3",
        [18] = "SCFA_VISIBLETORECON",
        [19] = "SERAPHIM",
        [20] = "SHIELD",
        [21] = "STRUCTURE",
        [22] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animactivate"] = {
                ["clipName"] = "AnimActivate",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3401/LOD0/uss3401.sananimation",
            },
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3401/LOD0/uss3401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3401/LOD0/uss3401.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
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
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
    },
}
