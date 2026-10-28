-- uss1702: Shou
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["progressBoundUpgradeAnimation"] = {
            ["animationKey"] = "source_animupgrade",
            ["durationSeconds"] = 1.4666666984558105,
            ["restAnimationKey"] = "walk",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.6,
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
            ["y"] = 0.15,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.6,
            ["y"] = 0.8,
            ["z"] = 0.6,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.uss2702) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "uss2702",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 80,
        ["cost"] = {
            ["alloys"] = 64,
            ["energy"] = 544,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 10,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Shou",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "intel",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_intel.png",
        ["iconUIBuildSortPriority"] = 290,
        ["iconUIType"] = "water",
        ["name"] = "Shou",
        ["orders"] = {
            ["Assist"] = true,
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Intel"] = true,
            ["Pause"] = false,
        },
        ["tpId"] = "uss1702",
        ["unitTypeName"] = "UnknownT1Sonar",
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
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_ENGINEER",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "CONSTRUCTION",
        [5] = "INTEL",
        [6] = "NAVAL",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER1ENGINEER",
        [9] = "SCFA_BUILTBYTIER2COMMANDER",
        [10] = "SCFA_BUILTBYTIER2ENGINEER",
        [11] = "SCFA_BUILTBYTIER3COMMANDER",
        [12] = "SCFA_BUILTBYTIER3ENGINEER",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_INTELLIGENCE",
        [15] = "SCFA_OVERLAYSONAR",
        [16] = "SCFA_PRODUCTFA",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SERAPHIM",
        [20] = "SCFA_SHOWQUEUE",
        [21] = "SCFA_SIZE4",
        [22] = "SCFA_SONAR",
        [23] = "SCFA_SORTINTEL",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH1",
        [26] = "SCFA_VISIBLETORECON",
        [27] = "SERAPHIM",
        [28] = "SONAR",
        [29] = "STRUCTURE",
        [30] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animupgrade"] = {
                ["authoredSpeed"] = 1,
                ["clipName"] = "AnimUpgrade",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1702/LOD0/uss1702.sananimation",
            },
            ["source_rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1702/LOD0/uss1702.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1702/LOD0/uss1702.sananimation",
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
        ["effectsInstant"] = {
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.35,
                    ["z"] = -0.12,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.294,
                    ["z"] = 0.108,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.12,
                    ["y"] = 0.374,
                    ["z"] = 0.096,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.108,
                    ["y"] = 0.486,
                    ["z"] = -0.12,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.132,
                    ["y"] = 0.4700000000000001,
                    ["z"] = 0.108,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 69,
            ["lod1distance"] = 179,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.6,
                ["y"] = 0.6,
            },
        },
    },
}
