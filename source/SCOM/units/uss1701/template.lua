-- uss1701: Esel
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["rotators"] = {
            [1] = {
                ["boneName"] = "Array",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 30,
                    ["z"] = 0,
                },
            },
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 0.9,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 2,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
        },
    },
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aclu2220",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 1,
            ["z"] = 0.5,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.uss2701) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "uss2701",
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
            ["energy"] = 20,
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
        ["displayName"] = "Esel",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "intel",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_intel.png",
        ["iconUIBuildSortPriority"] = 290,
        ["iconUIType"] = "land",
        ["name"] = "Esel",
        ["orders"] = {
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
        ["tpId"] = "uss1701",
        ["unitTypeName"] = "UnknownT1Radar",
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
        [4] = "CONSTRUCTION",
        [5] = "INTEL",
        [6] = "RADAR",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER1ENGINEER",
        [9] = "SCFA_BUILTBYTIER2COMMANDER",
        [10] = "SCFA_BUILTBYTIER2ENGINEER",
        [11] = "SCFA_BUILTBYTIER3COMMANDER",
        [12] = "SCFA_BUILTBYTIER3ENGINEER",
        [13] = "SCFA_DRAGBUILD",
        [14] = "SCFA_INTELLIGENCE",
        [15] = "SCFA_OVERLAYRADAR",
        [16] = "SCFA_PRODUCTFA",
        [17] = "SCFA_RADAR",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_SELECTABLE",
        [20] = "SCFA_SERAPHIM",
        [21] = "SCFA_SHOWQUEUE",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTINTEL",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH1",
        [26] = "SCFA_VISIBLETORECON",
        [27] = "SERAPHIM",
        [28] = "STRUCTURE",
        [29] = "TECH1",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1701/LOD0/uss1701.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1701/LOD0/uss1701.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.5,
                    ["z"] = -0.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.43,
                    ["z"] = 0.09,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 0.53,
                    ["z"] = 0.08,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 0.6699999999999999,
                    ["z"] = -0.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 0.65,
                    ["z"] = 0.09,
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
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 0.9,
            },
        },
    },
}
